use v6.c;
use Test;

plan 53;

# N.B.:  relational ops are in relational.t

# L<S03/Nonchaining binary precedence/Order::Less, Order::Same, or Order::More>
is(+Order::Less, -1, 'Order::Less numifies to -1');
is(+Order::Same,  0, 'Order::Same numifies to 0');
is(+Order::More,  1, 'Order::More numifies to 1');

#L<S03/Comparison semantics>

# spaceship comparisons (Num)
is(1 <=> 1, Order::Same, '1 <=> 1 is same');
is(1 <=> 2, Order::Less, '1 <=> 2 is less');
is(2 <=> 1, Order::More, '2 <=> 1 is more');

is 0 <=> -1,      Order::More, '0 <=> -1 is less';
is -1 <=> 0,      Order::Less, '-1 <=> 0 is more';
is 0 <=> -1/2,    Order::More, '0 <=> -1/2 is more';
is 0 <=> 1/2,     Order::Less, '0 <=> 1/2 is less';
is -1/2 <=> 0,    Order::Less, '-1/2 <=> 0 is more';
is 1/2 <=> 0,     Order::More, '1/2 <=> 0 is more';
is 1/2 <=> 1/2,   Order::Same, '1/2 <=> 1/2 is same';
is -1/2 <=> -1/2, Order::Same, '-1/2 <=> -1/2 is same';
is 1/2 <=> -1/2,  Order::More, '1/2 <=> -1/2 is more';
is -1/2 <=> 1/2,  Order::Less, '-1/2 <=> 1/2 is less';

is 1 <=> NaN, Nil, "NaN numeric comparison always produces Nil";
is NaN <=> 1, Nil, "NaN numeric comparison always produces Nil";
is NaN <=> NaN, Nil, "NaN numeric comparison always produces Nil";

is 1 cmp NaN, Less, "NaN generic comparison sorts NaN in with alphabetics";
is NaN cmp 1, More, "NaN generic comparison sorts NaN in with alphabetics";
is NaN cmp NaN, Same, "NaN generic comparison sorts NaN in with alphabetics";

is exp(i * pi) <=> -1, Same, "<=> ignores tiny imaginary values";
is exp(i * pi) * 1e10 <=> -1 * 1e10, Same, "<=> ignores tiny imaginary values, scaled up";
is exp(i * pi) * 1e-10 <=> -1 * 1e-10, Same, "<=> ignores tiny imaginary values, scaled down";
{
    my $*TOLERANCE = 1e-18;
    throws-like 'exp(i * pi) <=> -1', Exception, "(unless they exceed the signficance)";
    throws-like 'exp(i * pi) * 1e10 <=> -1 * 1e10', Exception, "(still fails scaled up)";
    throws-like 'exp(i * pi) * 1e-10 <=> -1 * 1e-10', Exception, "(still fails scaled down)";
}

# leg comparison (Str)
is('a' leg 'a',     Order::Same, 'a leg a is same');
is('a' leg 'b',     Order::Less, 'a leg b is less');
is('b' leg 'a',     Order::More, 'b leg a is more');
is('a' leg 1,       Order::More, 'leg is in string context');
is("a" leg "a\0",   Order::Less, 'a leg a\0 is less');
is("a\0" leg "a\0", Order::Same, 'a\0 leg a\0 is same');
is("a\0" leg "a",   Order::More, 'a\0 leg a is more');

# cmp comparison
is('a' cmp 'a',     Order::Same, 'a cmp a is same');
is('a' cmp 'b',     Order::Less, 'a cmp b is less');
is('b' cmp 'a',     Order::More, 'b cmp a is more');
is(1 cmp 1,         Order::Same, '1 cmp 1 is same');
is(1 cmp 2,         Order::Less, '1 cmp 2 is less');
is(2 cmp 1,         Order::More, '2 cmp 1 is more');
is('a' cmp 1,       Order::More, '"a" cmp 1 is more'); # unspecced P5 behavior
is("a" cmp "a\0",   Order::Less, 'a cmp a\0 is less');
is("a\0" cmp "a\0", Order::Same, 'a\0 cmp a\0 is same');
is("a\0" cmp "a",   Order::More, 'a\0 cmp a is more');

# compare numerically with non-numeric
{
    class Blue { 
        method Numeric() { 3; }
        method Real()    { 3; }
    } 
    my $a = Blue.new;

    ok +$a == 3, '+$a == 3 (just checking)';
    ok $a == 3, '$a == 3';
    ok $a != 4, '$a != 4';
    nok $a != 3, 'not true that $a != 3';

    lives-ok { $a < 5 }, '$a < 5 lives okay';
    lives-ok { $a <= 5 }, '$a <= 5 lives okay';
    lives-ok { $a > 5 }, '$a > 5 lives okay';
    lives-ok { $a >= 5 }, '$a => 5 lives okay';
}

# vim: ft=perl6
