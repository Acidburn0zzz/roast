use v6;
use lib <t/spec/packages/>;
use Test;
use Test::Util;

=begin description

Repeat operators for strings and lists

=end description

plan 63;

#L<S03/Changes to Perl 5 operators/"x (which concatenates repetitions of a string to produce a single string">

is('a' x 3, 'aaa', 'string repeat operator works on single character');
is('ab' x 4, 'abababab', 'string repeat operator works on multiple character');
is(1 x 5, '11111', 'number repeat operator works on number and creates string');
is('' x 6, '', 'repeating an empty string creates an empty string');
is('a' x 0, '', 'repeating zero times produces an empty string');
is('a' x -1, '', 'repeating negative times produces an empty string');
is('a' x 2.2, 'aa', 'repeating with a fractional number coerces to Int');
# RT #114670
is('str' x Int, '', 'x with Int type object');
# RT #125628
{
    throws-like(
        { 'a' x -NaN },
        Exception,
        message => 'Cannot coerce NaN to an Int',
        'repeating with -NaN fails'
    );
    throws-like(
        { 'a' x NaN },
        Exception,
        message => 'Cannot coerce NaN to an Int',
        'repeating with NaN fails'
    );
    throws-like(
        { 'a' x -Inf },
        Exception,
        message => 'Cannot coerce -Inf to an Int',
        'repeating with -Inf fails'
    );
    isa-ok('a' x Inf, Failure, 'repeating with Inf is a Failure');
    isa-ok('a' x *, WhateverCode, 'repeating with * is a WhateverCode');

    throws-like(
        { 'a' xx -NaN },
        Exception,
        message => 'Cannot coerce NaN to an Int',
        'list repeating with -NaN fails'
    );
    throws-like(
        { 'a' xx NaN },
        Exception,
        message => 'Cannot coerce NaN to an Int',
        'list repeating with NaN fails'
    );
    throws-like(
        { 'a' xx -Inf },
        Exception,
        message => 'Cannot coerce -Inf to an Int',
        'list repeating with -Inf fails'
    );
}
# RT #128035
#?rakudo.jvm skip 'OutOfMemoryError: Java heap space'
{
    my $a;
    lives-ok({ $a = 'a' x 1073741824 }, 'repeat count equal to the NQP limit works');
    is($a.chars, 1073741824, 'correct result for count equal to the NQP limit');

    throws-like({ $a = 'a' x 9999999999999999999 }, Exception, 'too large repeat count throws instead of going negative');
}

#L<S03/Changes to Perl 5 operators/"and xx (which creates a list of repetitions of a list or item)">
my @foo = 'x' xx 10;
is(@foo[0], 'x', 'list repeat operator created correct array');
is(@foo[9], 'x', 'list repeat operator created correct array');
is(+@foo, 10, 'list repeat operator created array of the right size');

lives-ok { my @foo2 = Mu xx 2; }, 'can repeat Mu';
my @foo3 = flat (1, 2) xx 2;
is(@foo3[0], 1, 'can repeat lists');
is(@foo3[1], 2, 'can repeat lists');
is(@foo3[2], 1, 'can repeat lists');
is(@foo3[3], 2, 'can repeat lists');

my @foo4 = 'x' xx 0;
is(+@foo4, 0, 'repeating zero times produces an empty list');

my @foo5 = 'x' xx -1;
is(+@foo5, 0, 'repeating negative times produces an empty list');

my @foo_2d = [1, 2] xx 2; # should create 2d
is(@foo_2d[1], [1, 2], 'can create 2d arrays'); # creates a flat 1d array
# Wrong/unsure: \(1, 2) does not create a ref to the array/list (1,2), but
# returns a list containing two references, i.e. (\1, \2).
#my @foo_2d2 = \(1, 2) xx 2; # just in case it's a parse bug
#is(@foo_2d[1], [1, 2], 'can create 2d arrays (2)'); # creates a flat 1d array

# test x=
my $twin = 'Lintilla';
ok($twin x= 2, 'operator x= for string works');
is($twin, 'LintillaLintilla', 'operator x= for string repeats correct');

# test that xx actually creates independent items
#?DOES 4
{
    my @a = 'a' xx 3;
    is @a.join('|'), 'a|a|a', 'basic infix:<xx>';
    @a[0] = 'b';
    is @a.join('|'), 'b|a|a', 'change to one item left the others unchanged';

    my @b = flat <x y> xx 3;
    is @b.join('|'), 'x|y|x|y|x|y', 'basic sanity with <x y> xx 3';
    @b[0] = 'z';
    @b[3] = 'a';
    is @b.join('|'), 'z|y|x|a|x|y', 'change to one item left the others unchanged';
}


# tests for non-number values on rhs of xx (RT #76720)
#?DOES 2
{
    # make sure repeat numifies rhs, but respects whatever
    my @a = <a b c>;
    is(("a" xx @a).join('|'), 'a|a|a', 'repeat properly numifies rhs');

    my @b = flat <a b c> Z (1 xx *);
    is(@b.join('|'), 'a|1|b|1|c|1', 'xx understands Whatevers');
}

# RT #101446
# xxx now thunks the LHS
{
    my @a = ['a'] xx 3;
    @a[0][0] = 'b';
    is @a[1][0], 'a', 'xx thunks the LHS';
}

# RT #123830
{
    is 'ABC'.ords xx 2, (65,66,67,65,66,67), "xx works on a lazy list";
}

# RT #125627
is ('foo' xx Inf)[8], 'foo', 'xx Inf';

ok (42 xx *).is-lazy, "xx * is lazy";
ok !(42 xx 3).is-lazy, "xx 3 is not lazy";

# RT #126576
is ((2, 4, 6) xx 2).elems, 2, 'xx retains structure with list on LHS';
is ((2, 4, 6) xx 2).flat.elems, 6, 'xx retained list structure can be flattened with .flat';
is ((2, 4, 6).Seq xx 2).elems, 2, 'xx retains structure with Seq on LHS';
is ((2, 4, 6).Seq xx 2).flat.elems, 6, 'xx retained Seq structure can be flattened with .flat';
is ((2, 4, 6) xx *)[^2], ((2, 4, 6), (2, 4, 6)),
    'xx * retains structure with list on LHS';
is ((2, 4, 6).Seq xx *)[^2], ((2, 4, 6), (2, 4, 6)),
    'xx * retains structure with Seq on LHS';

{
    # RT #128382
    my $is-sunk = 0;
    my class A { method sink() { $is-sunk++ } };
    my @a = A.new xx 10;
    is $is-sunk, 0, 'xx does not sink';
}

{ # coverage; 2016-10-11
    throws-like { infix:<xx>() }, Exception, 'xx with no args throws';
    is-deeply infix:<xx>(2), 2, 'xx with single arg is identity';

    is-deeply infix:<xx>({$++;}, *)[^200],  (|^200).Seq,
        '(& xx *) works as & xx Inf';
    is-deeply infix:<xx>({$++;}, Inf)[^20], (|^20).Seq,
        '(& xx Inf) works as & xx Inf';
    is-deeply infix:<xx>({$++;}, 4e0)[^4],  (|^4).Seq,
        '(& xx Num) works as & xx Int';
}

# RT 129899
{
    throws-like { 'a' x 'b' }, X::Str::Numeric, 'x does not silence failures';
    is-deeply 'a' x Int, '', 'type objects get interpreted as 0 iterations';
}

# RT #130288
{
    throws-like ｢rand xx '123aaa'｣, X::Str::Numeric,
        'Failures in RHS of xx explode (callable LHS)';
    throws-like ｢42   xx '123aaa'｣, X::Str::Numeric,
        'Failures in RHS of xx explode (Int LHS)';
}

# RT #130281
warns-like { 'x' x Int }, *.contains('uninitialized' & 'numeric'),
    'using an unitialized value in repeat count throws';

# RT #130619
is-deeply (|() xx *)[^5], (Nil, Nil, Nil, Nil, Nil),
    'empty slip with xx * works';

# RT #127971,130924
{
    dies-ok { my $a = "a" x 2**30; my $b = "b" x 2**30; my $c = $a ~ $b; my $d = $b ~ $a; my $e = $c ~ $d; },
        'concatenating strings with `~` that would create a too large result dies';
    dies-ok { (('a' x 1000000) x 1000000) },
        'repeating strings with `x` that would create a too large result dies';
}

# vim: ft=perl6
