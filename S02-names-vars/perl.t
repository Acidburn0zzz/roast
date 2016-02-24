use v6.c;
use Test;
plan 116;
# L<S02/Names and Variables/To get a Perlish representation of any object>

my @tests = (
    # Basic scalar values
    42, 
    42/10, 
    4.2, 
    sqrt(2),
    3e5,
    Inf, -Inf, NaN,

    "a string", "", "\0", "\t", "\n", 
    "\r\n", 
    "\o7",
    '{', # "\d123",	# XXX there is no \d escape!!!
    '}',
    '$a @string %with &sigils()',
    'שלום',

    ?1, ?0,
    #?niecza emit # Autoloading NYI
    rx:P5/foo/, rx:P5//, rx:P5/^.*$/,

    # Captures containing scalars
    \(42), \(Inf), \(-Inf), \(NaN), \("string"), \(""), \(?1), \(?0), 

    \Mu,

    (a => 1),
    :b(2),

    # Aggregates
    {},           # empty hash
    { a => 42 },  # only one elem
    { :a(1), :b(2), :c(3) },

    # Nested things
    { a => [1,2,3] },  # only one elem
    { a => [1,2,3], b => [4,5,6] },
    [ { :a(1) }, { :b(2), :c(3) } ],

    # a List
    <a b c>
);

# L<S02/Names and Variables/To get a Perlish representation of any object>
# Quoting S02 (emphasis added):
#   To get a Perlish representation of any data value, use the .perl method.
#   This will put quotes around strings, square brackets around list values,
#   curlies around hash values, etc., **such that standard Perl could reparse
#   the result**.
{
    for @tests -> $obj {
        my $s = (~$obj).subst(/\n/, '␤');
        ok EVAL($obj.perl).perl eq $obj.perl,
            "($s.perl()).perl returned something whose EVAL()ed stringification is unchanged";
        is WHAT(EVAL($obj.perl)).gist, $obj.WHAT.gist,
            "($s.perl()).perl returned something whose EVAL()ed .WHAT is unchanged";
    }
}

# Recursive data structures
#?rakudo.jvm skip "RT #126518"
{
    my $foo = { a => 42 }; $foo<b> = $foo;
    is $foo<b><b><b><a>, 42, "basic recursive hashref";

    #?niecza skip 'hanging test'
    ok $foo.perl,
        ".perl worked correctly on a recursive hashref";
}

{
    my $foo = [ 42 ];
    my $bar = { a => 23 };
    $foo[1] = $bar;
    $bar<b> = $foo;

    is $foo[1]<b>[1]<b>[0], 42, "mixed arrayref/hashref recursive structure";

    #?niecza skip 'hanging test'
    ok $foo.perl,
        ".perl worked correctly on a mixed arrayref/hashref recursive structure";
}

# RT #124242
{
    class Bug {
        has @.myself;
        method bind( $myself ) {
            @.myself[0] = $myself;
        }
    }
    my $a1 = Bug.new;
    $a1.bind( $a1 );
    say $a1;
    pass "survived saying a self-referencing object";
}

# RT #122286
{
    class Location {...}
    class Item {
        has Location $.loc is rw;
        method locate (Location $l) {
            self.loc=$l;
        }
        method whereis () {
            return self.loc;
        }
    }
    class Location {
        has Item @.items;
        method put (Item $item) {
            push(@.items, $item);
        }
    }
    my $i1=Item.new;
    my $l1=Location.new;
    $l1.put($i1);
    $i1.locate($l1);
    say $i1.whereis;
    pass "survived saying two mutually referencing objects";
}

{
    # test a bug reported by Chewie[] - apparently this is from S03
    is(EVAL((("f","oo","bar").keys.List).perl), <0 1 2>, ".perl on a .keys list");
}


# RT #61918
#?niecza skip ">>>Stub code executed"
{
    class RT61918 {
        has $.inst is rw;
        has $!priv;
        has $.string = 'krach';

        method init {
            $.inst = [ 0.451619069541592e0, 0.248524740881188e0 ];
            $!priv = [ 0.016026552444413e0, 0.929197054085006e0 ].perl;
        }
    }

    my $t1 = RT61918.new();
    my $t1_new = $t1.perl;
    $t1.init;
    my $t1_init = $t1.perl;

    ok $t1_new ne $t1_init, 'changing object changes .perl output';

    # TODO: more tests that show EVAL($t1_init) has the same guts as $t1.
    ok $t1_new ~~ /<< krach >>/, 'attribute value appears in .perl output';

    # RT #62002 -- validity of default .perl
    my $t2_init = EVAL($t1_init).perl;
    is $t1_init, $t2_init, '.perl on user-defined type roundtrips okay';
}

# RT #123048
#?rakudo.jvm todo 'RT #123048'
{
    my $a = 0.219947518065601987e0;
    is $a.perl, EVAL($a.perl).perl,
        '.perl on float with many digits roundtrips okay';
}

# RT #64080
{
    my %h;
    lives-ok { %h<a> = [%h<a>] },
             'can assign list with new hash element to itself';
    lives-ok { %h<a>.perl }, 'can take .perl from hash element';
    ok %h<a> !=== %h<a>[0], 'hoa does not refer to hash element';
}

# RT #67790
{
    class RT67790 {}
    lives-ok { RT67790.HOW.perl }, 'can .perl on .HOW';
    #?rakudo skip 'RT #67790'
    #?niecza skip '>>>Stub code executed'
    ok EVAL(RT67790.HOW.perl) === RT67790.HOW, '... and it returns the right thing';
}

# RT #69869
{
    is 1.0.WHAT.gist, Rat.gist, '1.0 is Rat';
    is EVAL( 1.0.perl ).WHAT.gist, Rat.gist, "1.0 perl'd and EVAL'd is Rat";
}


# RT #67948
{
    my @a;
    ([0, 0], [1, 1]).grep({@a.push: .perl; 1}).eager;
    for @a {
        my $n = EVAL($_);
        isa-ok $n, Array, '.perl in .grep works - type';
        is $n.elems, 2, '.perl in .grep works - number of elems';
        is $n[0], $n[1], '.perl in .grep works - element equality';
    }
}

# Buf
#?niecza skip 'Unhandled exception'
{
    my Blob $a = "asdf".encode();
    is EVAL($a.perl).decode("utf8"), "asdf";
}

{
    my $ch;
    lives-ok { $ch = EVAL 100.chr.perl }, '100.chr.perl - lives';
    is $ch, 100.chr, ".perl on latin character";
    $ch = '';

    lives-ok { $ch = EVAL 780.chr.perl }, '780.chr.perl - lives';
    is $ch, 780.chr, ".perl on composing character";

    # RT #125110
    my $non-print-then-combchar = 1.chr ~ 780.chr;
    lives-ok { $ch = EVAL $non-print-then-combchar.perl },
        '.perl on string with combining char on a non-printable - lives';
    is $ch, $non-print-then-combchar,
        ".perl on string with combining char on a non-printable - roundtrips";

    is "Ħ".perl.chars, 3, 'non-combining start does not need escaping';
}

# vim: ft=perl6
