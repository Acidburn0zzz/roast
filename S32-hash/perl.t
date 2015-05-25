use v6;
use Test;

plan 12;

#?niecza todo "cannot roundtrip hashes"
# simple hash
{
    my %h = a => 1, b => 2;
    is %h.perl,'{:a(1), :b(2)}<>', 
      'can we serialize a simple hash';
    my $rh = EVAL(%h.perl);
    is-deeply $rh, $%h, 'can we roundtrip simple hash';
    ok $rh.of    =:= Mu,  'make sure any value can be stored';
    ok $rh.keyof =:= Any, 'make sure keys are Any';
} #4

#?niecza skip "cannot roundtrip hashes with constrained values"
# hash with constrained values
{
    my Int %h = a => 1, b => 2;
    is %h.perl, 'Hash[Int].new("a" => 1, "b" => 2)'|'Hash[Int].new("b" => 2, "a" => 1)',
      'can we serialize a hash with constrained values';
    my $rh = EVAL(%h.perl);
    is-deeply $rh, %h, 'can we roundtrip hash constrained values';
    ok $rh.of    =:= Int, 'make sure roundtripped values are Int';
    ok $rh.keyof =:= Any, 'make sure roundtripped keys are Any';
} #4

#?niecza skip "cannot roundtrip hashes with constrained keys & values"
# hash with constrained keys & values
{
    my Int %h{Str} = a => 1, b => 2;
    is %h.perl, 'Hash[Int,Str].new("a" => 1, "b" => 2)'|'Hash[Int,Str].new("b" => 2, "a" => 1)',
      'can we serialize a hash with constrained keys & values';
    my $rh = EVAL(%h.perl);
    is-deeply $rh, %h, 'can we roundtrip hash constrained keys & values';
    ok $rh.of    =:= Int, 'make sure roundtripped values are Int';
    ok $rh.keyof =:= Str, 'make sure roundtripped keys are Str';
} #4

#vim: ft=perl6
