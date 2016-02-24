use v6.c;
use Test;

plan 6;

#?niecza todo "cannot roundtrip arrays"
# simple array
{
    my @a = 1,2;
    is @a.perl, '[1, 2]',
      'can we serialize a simple array';
    my $ra = EVAL(@a.perl);
    is-deeply $ra, @a, 'can we roundtrip simple array';
    ok $ra.of =:= Mu, 'make sure any value can be stored';
} #3

#?niecza skip "cannot roundtrip arrays with constrained values"
# array with constrained values
{
    my Int @a = 1,2;
    is @a.perl, 'Array[Int].new(1, 2)',
      'can we serialize a array with constrained values';
    my $ra = EVAL(@a.perl);
    is-deeply $ra, @a, 'can we roundtrip array constrained values';
    ok $ra.of =:= Int, 'make sure roundtripped values are Int';
} #3

#vim: ft=perl6
