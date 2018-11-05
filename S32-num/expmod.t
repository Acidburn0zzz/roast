use v6.d;
use Test;
plan 118;

# L<S32::Numeric/Numeric/"=item expmod">

=begin pod

Basic tests for the expmod() builtin

=end pod

for 2..30 -> $i {
    is 7.expmod($i, 10),   7 ** $i % 10,  "7.expmod($i, 10) == { 7 ** $i % 10 }";
    is 9.expmod($i, 10),   9 ** $i % 10,  "9.expmod($i, 10) == { 9 ** $i % 10 }";
    is expmod(11, $i, 8),  11 ** $i % 8,  "expmod(11, $i, 8) == { 11 ** $i % 8 }";
    is expmod(13, $i, 12), 13 ** $i % 12, "expmod(13, $i, 12) == { 13 ** $i % 12 }";
}

is 2988348162058574136915891421498819466320163312926952423791023078876139.expmod(
        2351399303373464486466122544523690094744975233415544072992656881240319,
        10 ** 40),
   1527229998585248450016808958343740453059, "Rosettacode example is correct";

# RT #130713
#?rakudo.jvm skip 'java.lang.ArithmeticException: BigInteger not invertible.'
#?DOES 1
{
  subtest '.expmod with negative powers does not hang' => {
    plan 3;
    is-deeply  42.expmod(-1,1),   0, '-1, 1';
    is-deeply  42.expmod(-42,42), 0, '-42, 42';

    #?rakudo skip 'hangs RT#130713'
    is-deeply  42.expmod(-1,7),   0, '-1. 7';
  }
}
