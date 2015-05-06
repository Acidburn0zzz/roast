use v6;
use Test;

plan 16;

# L<S13/"Type Casting"/"method postcircumfix:<{ }> (**@slice) {...}">
# basic tests to see if the methods overload correctly.

#?niecza skip 'No value for parameter $capture in TypeCastSub.postcircumfix:<( )>'
{
    my multi testsub ($a,$b) {   #OK not used
        return 1;
    }
    my multi testsub ($a) {   #OK not used
        return 2;
    }
    my multi testsub () {
        return 3;
    }
    class TypeCastSub {
        method postcircumfix:<( )> (|c) {return 'pretending to be a sub ' ~ testsub(|c) }
    }

    my $thing = TypeCastSub.new;
    is($thing(), 'pretending to be a sub 3', 'overloaded () call works');
    is($thing.(), 'pretending to be a sub 3', 'overloaded .() call works');
    is($thing.(1), 'pretending to be a sub 2', 'overloaded .() call works');
    is($thing.(1,2), 'pretending to be a sub 1', 'overloaded .() call works');
}

#?rakudo skip 'cannot easily override [] at the moment RT #124971'
{
    class TypeCastArray {
        method postcircumfix:<[ ]> (*@slice) {  # METHOD TO SUB CASUALTY
            return 'pretending to be an array';
        }   #OK not used
    }

    my $thing = TypeCastArray.new;
    is($thing[1], 'pretending to be an array', 'overloaded [] call works');
    is($thing[2,3], 'pretending to be an array', 'overloaded [] call works (slice)');
    is($thing.[4], 'pretending to be an array', 'overloaded .[] call works');
    is($thing.[5,6], 'pretending to be an array', 'overloaded .[] call works (slice)');
}

#?rakudo skip 'cannot easily override {} at the moment RT #124972'
{
    class TypeCastHash {
        method postcircumfix:<{ }> (*@slice) {   # METHOD TO SUB CASUALTY
            return 'pretending to be a hash';
        }   #OK not used
    }

    my $thing = TypeCastHash.new;
    is($thing{'a'}, 'pretending to be a hash', 'overloaded {} call works');
    is($thing{'b','c'}, 'pretending to be a hash', 'overloaded {} call works (slice)');
    is($thing.{'d'}, 'pretending to be a hash', 'overloaded .{} call works');
    is($thing.{'e','f'}, 'pretending to be a hash', 'overloaded .{} call works (slice)');
    is($thing<a>, 'pretending to be a hash', 'overloaded <> call works');
    is($thing<b c>, 'pretending to be a hash', 'overloaded <> call works (slice)');
    is($thing.<d>, 'pretending to be a hash', 'overloaded .<> call works');
    is($thing.<e f>, 'pretending to be a hash', 'overloaded .<> call works (slice)');
}

# vim: ft=perl6
