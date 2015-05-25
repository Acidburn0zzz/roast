use Test;
use lib 't/spec/packages';
use Test::Util;

plan 33;

my $precomp-ext    := $*VM.precomp-ext;
my $precomp-target := $*VM.precomp-target;
my @precomp-paths;

for <C A B> {
    my $path = "t/spec/packages/Example/{$_}.pm";
    my $precomp-path = $path ~ '.' ~ $precomp-ext;
    unlink $precomp-path; # don't care if failed

    ok CompUnit.new($path).precomp, "precomp Example::$_";
    ok $precomp-path.IO.e, "created $precomp-path";
    @precomp-paths.push: $precomp-path;
}

my @keys = Test::Util::run( q:to"--END--").lines;
    use lib 't/spec/packages';
    use Example::A;
    use Example::B;

    .say for Example::.keys.sort;
    --END--

#?rakudo.jvm todo 'RT #122773'
is-deeply @keys, [<A B C>], 'Diamond relationship';

#?rakudo.jvm todo 'RT #122896'
#?rakudo.moar todo 'RT #122896'
is_run
  'use lib "t/spec/packages";
   use Example::C;
   f();',
   { err => '',
     out => '',
     status => 0,
   },
   'precompile exported cached sub';

unlink $_ for @precomp-paths; # don't care if worked

# RT #76456
{
    my $cur  = CompUnitRepo::Local::File.new("t/spec/packages");

    my ($cu) = $cur.candidates('RT76456');
    ok $cu.precomp(:force), 'precompiled a parameterized role';
    unlink $cu.precomp-path; # don't care if failed
}

#RT #122447
{
    # also a test of precompilation from the command line
    my $module-name = 'RT122447';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $precomp-ext;
    unlink $output-path; # don't care if failed

    is_run
      'sub foo($bar) {
           Proxy.new( FETCH => sub (|) { }, STORE => sub (|) { } );
       }',
      { err    => '',
        out    => '',
        status => 0
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path,
      ],
      'precompile sub with params returning a proxy';
    ok $output-path.IO.e, "did we create a $output-path";

    is_run
      '0',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '-I', 't/spec/packages',
        '-M', $module-name,
      ],
      'precompile load - from the command line';

    unlink $output-path; # don't care if failed
}

#RT #115240
{
    my $module-name = 'RT115240';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $precomp-ext;
    unlink $output-path; # don't care if failed

    is_run
      'role Foo [ ] { };
       role Bar does Foo[] { }',
       { err    => '',
         out    => '',
         status => 0,
       },
       :compiler-args[
         '--target', $precomp-target,
         '--output', $output-path,
       ],
       "precomp curried role compose";
    ok $output-path.IO.e, "did we create a $output-path";

    is_run
      "use $module-name;
       class C does Bar \{ \};",
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '-I', 't/spec/packages',
        '-M', $module-name,
      ],
      'precompile load - from the command line';

    unlink $output-path; # don't care if failed
}

#RT #123276
{
    my $name = 'RT123276';

    for "{$name}", "{$name}::B::C1", "{$name}::B::C2" -> $module-name {
        my $module-dir = join '/', split('::', $module-name);
        my $path = "t/spec/packages/{$module-dir}.pm";
        my $precomp-path = $path ~ '.' ~ $precomp-ext;
        unlink $precomp-path; # don't care if failed

        ok CompUnit.new($path).precomp(), "precomp Example::$_";
        @precomp-paths.push: $precomp-path;
    }

    my @keys = Test::Util::run( q:to"--END--").lines;
        use lib 't/spec/packages';
        use RT123276::B::C1;
        use RT123276::B::C2;
        say RT123276::B::C1.^methods
    --END--

    #?rakudo.jvm todo 'RT #123276'
    #?rakudo.moar todo 'RT #123276'
    is-deeply @keys, [<foo>], 'RT123276';

    unlink $_ for @precomp-paths;  # don't care if failed
}

#RT #124162
{
    my $module-name = 'RT124162';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $precomp-ext;
    unlink $output-path; # don't care if failed

    is_run
      'my @f = $(array[uint32].new(0,1)), $(array[uint32].new(3,4));',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path,
      ],
      "precomp of native array parameterization";
    ok $output-path.IO.e, "did we create a $output-path";

    is_run
      "use $module-name;",
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '-I', 't/spec/packages',
        '-M', $module-name,
      ],
      'precompile load - from the command line';

    unlink $output-path; # don't care if failed
}

{
    my $module-name-a = 'InternArrayA';
    my $output-path-a = "t/spec/packages/" ~ $module-name-a ~ '.pm.' ~ $precomp-ext;
    unlink $output-path-a; # don't care if failed
    is_run
      'my constant VALUE = array[uint32].new;
       sub a() is export { VALUE }',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path-a,
      ],
      "precomp of native array parameterization intern test (a)";
    ok $output-path-a.IO.e, "did we create a $output-path-a";

    my $module-name-b = 'InternArrayB';
    my $output-path-b = "t/spec/packages/" ~ $module-name-b ~ '.pm.' ~ $precomp-ext;

    unlink $output-path-b; # don't care if failed

    is_run
      'my constant VALUE = array[uint32].new;
       sub b() is export { VALUE }',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path-b,
      ],
      "precomp of native array parameterization intern test (b)";
    ok $output-path-b.IO.e, "did we create a $output-path-b";

    #?rakudo.jvm todo 'no 6model parametrics interning yet'
    #?rakudo.moar todo 'no 6model parametrics interning yet'
    is_run
      "use $module-name-a;
       use $module-name-b;
       print a().WHAT =:= b().WHAT",
      { err    => '',
        out    => "True",
        status => 0,
      },
      :compiler-args['-I', 't/spec/packages'],
      'precompile load of both and identity check passed';

    unlink $_ for $output-path-a, $output-path-b; # don't care if failed
}


# RT #125090
{
    my $module-name = 'RT125090';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $precomp-ext;
    unlink $output-path; # don't care if failed

    is_run
      'BEGIN $*KERNEL;',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path,
      ],
      'precomp of BEGIN using $*KERNEL';
    ok $output-path.IO.e, "did we create a $output-path";

    is_run
      "use $module-name; say 33;",
      { err    => '',
        out    => "33\n",
        status => 0,
      },
      :compiler-args[
        '-I', 't/spec/packages'
      ],
      'precompile load - from the command line';

    unlink $output-path; # don't care if failed
}
{
    my $module-name = 'RT125090';
    my $output-path = "t/spec/packages/" ~ $module-name ~ '.pm.' ~ $precomp-ext;
    unlink $output-path; # don't care if failed

    is_run
      'BEGIN $*DISTRO;',
      { err    => '',
        out    => '',
        status => 0,
      },
      :compiler-args[
        '--target', $precomp-target,
        '--output', $output-path,
      ],
      'precomp of BEGIN using $*DISTRO';
    ok $output-path.IO.e, "did we create a $output-path";

    is_run
      "use $module-name; say 42;",
      { err    => '',
        out    => "42\n",
        status => 0,
      },
      :compiler-args[
        '-I', 't/spec/packages'
      ],
      'precompile load - from the command line';

    unlink $output-path; # don't care if failed
}
