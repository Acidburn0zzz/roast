use v6;
use Test;

plan 88;

#L<S04/The Relationship of Blocks and Declarations/"declarations, all
# lexically scoped declarations are visible"> 
{

    eval_dies_ok('$x; my $x = 42', 'my() variable not yet visible prior to declaration');
    is(EVAL('my $x = 42; $x'), 42, 'my() variable is visible now (2)');
}


{
    my $ret = 42;
    eval_dies_ok '$ret = $x ~ my $x;', 'my() variable not yet visible (1)';
    is $ret, 42,                       'my() variable not yet visible (2)';
}

{
    my $ret = 42;
    lives_ok { $ret = (my $x) ~ $x }, 'my() variable is visible (1)';
    is $ret, "",                      'my() variable is visible (2)';
}

{
    sub answer { 42 }
    my &fortytwo = &answer;
    is &fortytwo(), 42,               'my variable with & sigil works (1)';
    is fortytwo(),  42,               'my variable with & sigil works (2)';
}

{
  my $was_in_sub;
  my &foo := -> $arg { $was_in_sub = $arg };
  foo(42);
  is $was_in_sub, 42, 'calling a lexically defined my()-code var worked';
}

eval_dies_ok 'foo(42)', 'my &foo is lexically scoped';

{
  is(do {my $a = 3; $a}, 3, 'do{my $a = 3; $a} works');
  is(do {1; my $a = 3; $a}, 3, 'do{1; my $a = 3; $a} works');
}

eval_lives_ok 'my $x = my $y = 0; #OK', '"my $x = my $y = 0" parses';

{
    my $test = "value should still be set for arg, even if there's a later my";
    sub foo2 (*%p) {
        is(%p<a>, 'b', $test);
        my %p; #OK
    }
    foo2(a => 'b');
}

my $a = 1;
ok($a, '$a is available in this scope');

if (1) { # create a new lexical scope
    ok($a, '$a is available in this scope');
    my $b = 1;
    ok($b, '$b is available in this scope');
}
eval_dies_ok '$b', '$b is not available in this scope';

# changing a lexical within a block retains the changed value
my $c = 1;
if (1) { # create a new lexical scope
    is($c, 1, '$c is still the same outer value');
    $c = 2;
}
is($c, 2, '$c is available, and the outer value has been changed');

# L<S04/The Relationship of Blocks and Declarations/prior to the first declaration>

my $d = 1;
{ # create a new lexical scope
    is($d, 1, '$d is still the outer $d');
    { # create another new lexical scope
        my $d = 2;
        is($d, 2, '$d is now the lexical (inner) $d');    
    }
}
is($d, 1, '$d has not changed');

# EVAL() introduces new lexical scope
is( EVAL('
my $d = 1;
{ 
    my $d = 3 #OK not used
};
$d;
'), 1, '$d is available, and the outer value has not changed' );

{
    # check closures with functions
    my $func;
    my $func2;
    if (1) { # create a new lexical scope
        my $e = 0;
        $func = sub { $e++ }; # one to inc
        $func2 = sub { $e };  # one to access it
    }

    eval_dies_ok '$e', '$e is not available in this scope';
    is($func2(), 0, '$func2() just returns the $e lexical which is held by the closure');
    $func();
    is($func2(), 1, '$func() increments the $e lexical which is held by the closure');
    $func();
    is($func2(), 2, '... and one more time just to be sure');
}

# check my as simultaneous lvalue and rvalue

is(EVAL('my $e1 = my $e2 = 42 #OK'), 42, 'can parse squinting my value');
is(EVAL('my $e1 = my $e2 = 42; $e1 #OK'), 42, 'can capture squinting my value');
is(EVAL('my $e1 = my $e2 = 42; $e2 #OK'), 42, 'can set squinting my variable');
is(EVAL('my $x = 1, my $y = 2; $y #OK'), 2, 'precedence of my wrt = and ,');

# test that my (@array, @otherarray) correctly declares
# and initializes both arrays
{
    my (@a, @b);
    lives_ok { @a.push(2) }, 'Can use @a';
    lives_ok { @b.push(3) }, 'Can use @b';
    is ~@a, '2', 'push actually worked on @a';
    is ~@b, '3', 'push actually worked on @b';
}

my $result;
my $x = 0;
{
    while my $x = 1 { $result = $x; last };
    is $result, 1, 'my in while cond seen from body';
}

is(EVAL('while my $x = 1 { last }; $x'), 1, 'my in while cond seen after');

is(EVAL('if my $x = 1 { $x } else { 0 }'), 1, 'my in if cond seen from then');
is(EVAL('if not my $x = 1 { 0 } else { $x }'), 1, 'my in if cond seen from else');
is(EVAL('if my $x = 1 { 0 } else { 0 }; $x'), 1, 'my in if cond seen after');

# check proper scoping of my in loop initializer

is(EVAL('loop (my $x = 1, my $y = 2; $x > 0; $x--) { $result = $x; last }; $result #OK'), 1, '1st my in loop cond seen from body');
is(EVAL('loop (my $x = 1, my $y = 2; $x > 0; $x--) { $result = $y; last }; $result #OK'), 2, '2nd my in loop cond seen from body');
is(EVAL('loop (my $x = 1, my $y = 2; $x > 0; $x--) { last }; $x #OK'), 1, '1st my in loop cond seen after');
is(EVAL('loop (my $x = 1, my $y = 2; $x > 0; $x--) { last }; $y #OK'), 2, '2nd my in loop cond seen after');


# check that declaring lexical twice is noop
{
    my $f;
    $f = 5;
    my $f; #OK
    is($f, 5, "two lexicals declared in scope is noop");
}

my $z = 42; #OK not used
{
    my $z = $z;
    nok( $z.defined, 'my $z = $z; can not see the value of the outer $z');
}

# interaction of my and EVAL
# yes, it's weird... but that's the way it is
# http://irclog.perlgeek.de/perl6/2009-03-19#i_1001177
{
    sub eval_elsewhere($str) {
        EVAL $str;
    }
    my $x = 4; #OK not used
    is eval_elsewhere('$x + 1'), 5, 
       'EVAL() knows the pad where it is launched from';

    ok eval_elsewhere('!$y.defined'),
       '... but initialization of variables might still happen afterwards';

    # don't remove this line, or EVAL() will complain about 
    # $y not being declared
    my $y = 4; #OK not used
}

# &variables don't need to be pre-declared
# (but they need to exist by CHECK)
{
    eval_lives_ok '&x; 1; sub x {}', '&x does not need to be pre-declared';
    eval_dies_ok '&x()', '&x() dies when empty';
}

# RT #62766
{
    eval_lives_ok 'my $a;my $x if 0;$a = $x', 'my $x if 0';

    eval_lives_ok 'my $a;do { die "foo"; my $x; CATCH { default { $a = $x.defined } } }';

    {
        ok EVAL('not OUTER::<$x>.defined'), 'OUTER::<$x>';
        ok EVAL('not SETTING::<$x>.defined'), 'SETTING::<$x>';
        my $x; #OK not used
    }

    {
        my $a;
        #?rakudo todo 'fails'
        #?niecza 2 todo 'still fails?'
        eval_lives_ok 'do { die "foo";my Int $x;CATCH { default { $a = ?($x ~~ Int) } } }';
        #?rakudo todo 'previous test skipped'
        ok $a, 'unreached declaration in effect at block start';
    }

    # XXX As I write this, this does not die right.  more testing needed.
    dies_ok { my Int $x = "abc" }, 'type error'; #OK
    dies_ok { EVAL '$x = "abc"'; my Int $x; }, 'also a type error';
}

# RT #102414
{
    # If there is a regression this may die not just fail to make ints
#?rakudo.jvm todo 'RT #102414 still unresolved'
    eval_lives_ok 'my (int $a);','native in declarator sig';
#?rakudo.jvm todo 'RT #102414 still unresolved'
    eval_lives_ok 'my (int $a, int $b);','natives in declarator sig';

#?rakudo todo 'RT #102414 still unresolved'
    throws_like { my (Int $a); $a = "str" }, X::TypeCheck, 'Type in declarator sig 1/1 constrains';
#?rakudo todo 'RT #102414 still unresolved'
    throws_like { my (Int $a, Int $b); $b = "str" }, X::TypeCheck, 'Types in declarator sig 1/2 constrain';
#?rakudo todo 'RT #102414 still unresolved'
    throws_like { my (Int $a, Int $b); $b = "str" }, X::TypeCheck, 'Types in declarator sig 2/2 constrain';


    # These still need spec clarification but test them, since they pass
    eval_lives_ok 'my int ($a);', 'native outside declarator sig 1';
    eval_lives_ok 'my int ($a, $b)', 'native outside declarator sig 2';
    throws_like { my Int ($a); $a = "str" }, X::TypeCheck, 'Type outside declarator sig 1/1 constrains';
    throws_like { my Int ($a, $b); $a = "str" }, X::TypeCheck, 'Type outside declarator sig 1/2 constrains';
    throws_like { my Int ($a, $b); $b = "str"}, X::TypeCheck, 'Type outside declarator sig 2/2 constrains';
}

{
    nok declare_later().defined,
        'Can access variable returned from a named closure that is declared below the calling position';
    my $x;
    sub declare_later {
        $x;
    }
}

# used to be RT #76366, #76466
#?rakudo skip 'nom regression, OUR::'
{
    nok OUR::access_lexical_a().defined,
        'can call our-sub that accesses a lexical before the block was run';
    {
        my $a = 42;
        our sub access_lexical_a() { $a }
    }
    #?niecza todo 'NYI'
    is  OUR::access_lexical_a(), 42,
        'can call our-sub that accesses a lexical after the block was run';

}

eval_lives_ok 'my (%h?) #OK', 'my (%h?) lives';

#RT 63588
eval_lives_ok 'my $x = 3; class A { has $.y = $x; }; A.new.y.gist',
        'global scoped variables are visible inside class definitions';

#RT #72814
{
    #?niecza skip 'a not predeclared'
    lives_ok {my ::a $a}, 'typing a my-declared variable as ::a works.';    #OK not used
}

# RT #72946
{
    is ( my $ = 'foo' ), 'foo',
        'declaration of anonymous Scalar';
    is ( my @ = 'foo', 'bar', 'baz' ), ['foo', 'bar', 'baz'],
        'declaration of anonymous Array';
    is ( my % = 'foo' => 1, 'bar' => 2, 'baz' => 3 ), {'foo' => 1, 'bar' => 2, 'baz' => 3},
        'declaration of anonymous Hash';
}

# RT #76452
eval_lives_ok 'multi f(@a) { }; multi f(*@a) { }; f(my @a = (1, 2, 3))',
              'can declare a variable inside a sub call';

# RT #77112
# check that the presence of routines is checked before run time 
{
    my $bad = 0;
    dies_ok { EVAL '$bad = 1; no_such_routine()' },
        'dies on undeclared routines';
    nok $bad, '... and it does so before run time';
}

#RT #102650
{
    my @tracker;
    my $outer;
    sub t() {
        my $inner = $outer++;
        @tracker.push($inner) and t() for $inner ?? () !! ^2;
    }
    t();
    is @tracker.join(', '), '0, 0', 'RT 102650';
}

# RT #114202
# # check that anonymous variables don't overshare.
#?niecza skip 'parsefail'
{
    my @ = 1, 2, 3;
    my % = a => 1, b => 2, c => 3;
    my & = { * - 5 };
    is my @, Array.new, q{anonymous @ doesn't overshare};
    is my %, ().hash, q{anonymous % doesn't overshare};
    ok (my &) eqv Callable, q{anonymous sub doesn't overshare};
}

# RT 117043
#?rakudo todo 'RT #117043'
{
    my (\x1) = 1;
    is \x1, 1,
        'can declare sigilless within parenthesis';
    my ($x2, \x3) = (2, 3);
    is ($x2, \x3).join(" "), '2 3',
        'declarator with multiple variables can contain sigilless';
}

{
    is my sub {42}(), 42, 'can call postcircumfix () on subs inside my'
}

# vim: ft=perl6
