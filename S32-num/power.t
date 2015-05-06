use v6;

use Test;

plan 52;

# Real **
is(0 ** 0,    1, "0 ** 0 ==  1");
is(0 ** 1,    0, "0 ** 1 ==  0");
is(1 ** 2,    1, "1 **  2 ==  1");
is(4 ** 0,    1, "4 **  0 ==  1");
is(4 ** 1,    4, "4 **  1 ==  4");
is(4 ** 2,   16, "4 **  2 == 16");

is 0 ** 4553535345364535345634543534, 0, "0 ** 4553535345364535345634543534 == 0";
is 1 ** 4553535345364535345634543534, 1, "1 ** 4553535345364535345634543534 == 1";
is 1e0 ** 4553535345364535345634543534, 1, "1e0 ** 4553535345364535345634543534 == 1";
isa-ok 1e0 ** 4553535345364535345634543534, Num, "1e0 ** 4553535345364535345634543534 is a Num";
#?rakudo.moar 5 todo 'big exponents RT #124798'
is (-1) ** 4553535345364535345634543534, 1, "-1 ** 4553535345364535345634543534 == 1";
is (-1) ** 4553535345364535345634543533, -1, "-1 ** 4553535345364535345634543534 == -1";
#?niecza skip "Slow and wrong"
is 2 ** 4553535345364535345634543534, Inf, "2 ** 4553535345364535345634543534 == Inf";
#?niecza 2 skip "Slow and wrong"
is (-2) ** 4553535345364535345634543534, Inf, "-2 ** 4553535345364535345634543534 == Inf";
is (-2) ** 4553535345364535345634543533, -Inf, "-2 ** 4553535345364535345634543534 == -Inf";

is(4 ** 0.5,  2, "4 ** .5 ==  2");
is(4 ** (1/2), 2, "4 ** (1/2) == 2 ");
is(4 ** (-1/2), 0.5, "4 ** (-1/2) == 1/2 ");
is((-2) ** 2, 4, "-2 ** 2 = 4");

#?niecza todo '#87'
is(1 ** Inf, 1, '1**Inf=1');
is(0 ** Inf, 0, '0**Inf=0');
is(Inf ** 2, Inf, 'Inf**2 = Inf');
is((-Inf) ** 3, -Inf, '(-Inf)**3 = -Inf');
is(Inf ** Inf, Inf, 'Inf**Inf = Inf');
is(NaN ** 2, NaN, "NaN propagates with integer powers");
is(NaN ** 3.14, NaN, "NaN propagates with numeric powers");
is(0 ** NaN, NaN, "0**NaN=NaN");

# Not at all sure the next three cases are correct!

#?niecza 2 todo 'complex NaN stringy'
#?rakudo.jvm skip 'NaN**1i should be NaN RT #124800'
#?rakudo.moar todo 'NaN**1i should be NaN RT #124802'
is(NaN ** 1i, NaN, "NaN**1i=NaN");
#?rakudo.jvm skip '1i**NaN should be NaN RT #124803'
#?rakudo.moar todo '1i**NaN should be NaN RT #124805'
is(1i ** NaN, NaN, "1i**NaN=NaN");
#?rakudo.jvm skip 'NaN**0 should be NaN RT #124806'
#?rakudo.moar todo 'NaN**0 should be NaN RT #124808'
is(NaN ** 0, NaN, "NaN**0=NaN");

is(NaN ** NaN, NaN, "NaN**NaN=NaN");
is(Inf ** NaN, NaN, "Inf**NaN=NaN");
is(NaN ** Inf, NaN, "NaN**Inf=NaN");

is_approx(exp(1) ** 0.5,  exp(0.5), "e **  .5 ==   exp(.5)");
is_approx(exp(1) ** 2.5,  exp(2.5), "e ** 2.5 ==  exp(2.5)");

# Complex ** Real
# These work by accident even if you don't have Complex **
is_approx((4 + 0i) ** 2, 4 ** 2, "(4+0i) ** 2 == 16");
is_approx(1i ** 4, 1, "i ** 4 == 1");
is_approx((4 + 0i) ** .5, 2, "(4+0i) ** .5 == 2");

is_approx(1i ** 2, -1, "i ** 2 == -1");
is_approx(1i ** 3, -1i, "i ** 3 == -i");
is_approx(5i ** 3, -125i, "5i ** 3 = -125i");
is_approx(3i ** 3, -27i, "3i ** 3 = -27i");
is_approx((-3i) ** 3, 27i, "-3i ** 3 = 27i");

#?rakudo.jvm skip 'i RT #124810'
#?rakudo.moar todo 'i RT #124811'
is_approx (-1) ** -i, 23.1406926327793, "(-1) ** -i is approx 23.1406926327793";

{
    for (8i).roots(4) -> $z {
        is_approx($z ** 4, 8i, "quartic root of 8i ** 4 = 8i");
    }
}

# Real ** Complex
{
    is_approx(exp(1) ** (pi * 1i), -1, "e ** pi i = -1");
}

# Complex ** Complex
is_approx((4 + 0i) ** (2 + 0i), 4 ** 2, "(4+0i) ** (2+0i) == 16");

# Rat ** a large number
ok(1.015 ** 200 !~~ NaN, "1.015 ** 200 is not NaN");
is_approx(1.015 ** 200, 19.6430286394751, "1.015 ** 200 == 19.6430286394751");

done;

# vim: ft=perl6
