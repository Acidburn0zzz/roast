use v6;

use Test;

plan 52;

# L<S02/Names and Variables/:exists>
# L<S32::Containers/"Array"/=item exists>

#?niecza skip "no adverbials"
{
    my @array = <a b c d>;
    ok @array[0]:exists,    "exists(positive index) on arrays (1)";
    ok @array[1]:exists,    "exists(positive index) on arrays (2)";
    ok @array[2]:exists,    "exists(positive index) on arrays (3)";
    ok @array[3]:exists,    "exists(positive index) on arrays (4)";
    ok @array[4]:!exists,   "exists(positive index) on arrays (5)";
    nok @array[42]:exists,  "exists(positive index) on arrays (6)";
}

#-------------------------------------------------------------------------------
# initialisations

my $default = Any;
my $dont    = False;
sub gen_array { (1..10).list }

#-------------------------------------------------------------------------------
# Array

{
    my @a = gen_array;
    is @a.elems, 10, "basic sanity";

    #?niecza 4 skip "no adverbials"
    isa-ok @a[ 3]:exists, Bool,  "Bool test for exists single element";
    isa-ok @a[ 3]:!exists, Bool, "!Bool test for exists single element";
    isa-ok @a[10]:exists, Bool,  "Bool test for non-exists single element";
    isa-ok @a[10]:!exists, Bool, "!Bool test for non-exists single element";
    ok     @a[ 3]:exists,        "Test for exists single element";
    ok   !(@a[10]:exists),       "Test for non-exists single element";

    #?niecza 10 skip "no adverbials"
    ok !(@a[ 9]:!exists),       "Test non-exists with ! single elem 9";
    ok   @a[10]:!exists,        "Test non-exists with ! single elem 10";
    ok !(@a[ 9]:exists(0)),     "Test non-exists with (0) single elem 9";
    ok   @a[10]:exists(0),      "Test non-exists with (0) single elem 10";
    ok !(@a[ 9]:exists(False)), "Test non-exists with (False) single elem 9";
    ok   @a[10]:exists(False),  "Test non-exists with (False) single elem 10";
    ok !(@a[ 9]:exists($dont)), "Test non-exists with (\$dont) single elem 9";
    ok   @a[10]:exists($dont),  "Test non-exists with (\$dont) single elem 10";
    ok   @a[ 9]:exists(1),      "Test exists with (1) single elem 9";
    ok !(@a[10]:exists(1)),     "Test exists with (1) single elem 10";

    is_deeply @a[1,2, 4]:exists,   (True, True, True),   "Test exists TTT";
    is_deeply @a[1,2,10]:exists,   (True, True, False),  "Test exists TTF";
    is_deeply (@a[]:exists), True xx 10,            "Test non-exists T[]";
    is_deeply (@a[*]:exists), True xx 10,           "Test non-exists T[*]";
    #?niezca 3 todo "adverbial pairs only used as True"
    is_deeply @a[1,2, 4]:!exists,  (False,False,False),  "Test non-exists FFF";
    is_deeply @a[1,2,10]:!exists,  (False,False,True),   "Test non-exists FFT";
    is_deeply (@a[]:!exists), False xx 10,          "Test non-exists F[]";
    is_deeply (@a[*]:!exists), False xx 10,         "Test non-exists F[*]";

    #?niezca 6 todo "no combined adverbial pairs"
    is_deeply @a[1,2, 4]:exists:kv,
      (1,True,2,True,4,True),                     "Test exists:kv TTT";
    is_deeply @a[1,2,10]:exists:kv,
      (1,True,2,True),                            "Test exists:kv TT.";
    is_deeply @a[1,2,10]:exists:!kv,
      (1,True,2,True,10,False),                   "Test exists:!kv TTF";
    is_deeply @a[1,2, 4]:!exists:kv,
      (1,False,2,False,4,False),                  "Test !exists:kv FFF";
    is_deeply @a[1,2,10]:!exists:kv,
      (1,False,2,False),                          "Test !exists:kv FF.";
    is_deeply @a[1,2,10]:!exists:!kv,
      (1,False,2,False,10,True),                  "Test !exists:kv FFT";

    #?niezca 6 todo "no combined adverbial pairs"
    is_deeply @a[1,2, 4]:exists:p,
      (1=>True,2=>True,4=>True),                  "Test exists:p TTT";
    is_deeply @a[1,2,10]:exists:p,
      (1=>True,2=>True),                          "Test exists:p TT.";
    is_deeply @a[1,2,10]:exists:!p,
      (1=>True,2=>True,10=>False),                "Test exists:!p TTF";
    is_deeply @a[1,2, 4]:!exists:p,
      (1=>False,2=>False,4=>False),               "Test !exists:p FFF";
    is_deeply @a[1,2,10]:!exists:p,
      (1=>False,2=>False),                        "Test !exists:p FF.";
    is_deeply @a[1,2,10]:!exists:!p,
      (1=>False,2=>False,10=>True),               "Test !exists:!p FFT";

    #?niezca 6 todo "no combined adverbial pairs"
    dies_ok { @a[1]:exists:k },    "Test exists:k,   invalid combo";
    dies_ok { @a[1]:exists:!k },   "Test exists:!k,  invalid combo";
    dies_ok { @a[1]:!exists:k },   "Test !exists:k,  invalid combo";
    dies_ok { @a[1]:!exists:!k },  "Test !exists:!k, invalid combo";

    #?niezca 6 todo "no combined adverbial pairs"
    dies_ok { @a[1]:exists:v },    "Test exists:v,   invalid combo";
    dies_ok { @a[1]:exists:!v },   "Test exists:!v,  invalid combo";
    dies_ok { @a[1]:!exists:v },   "Test !exists:v,  invalid combo";
    dies_ok { @a[1]:!exists:!v },  "Test !exists:!v, invalid combo";

    is @a.elems, 10, "should be untouched";
} #46

# vim: ft=perl6
