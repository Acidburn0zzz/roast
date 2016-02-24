use v6.c;
# http://perl6advent.wordpress.com/2010/12/19/day-19-false-truth/

use Test;
plan 6;

{
    my $value = 42 but role { method Bool  { False } };
    is $value, 42, 'but role {...}';
    is ?$value, False, 'but role {...}';
}

{
    my $value = 42 but False;
    is $value, 42, '42 but False';
    #?rakudo.jvm todo "RT #126491"
    is ?$value, False, '42 but False';
}

{
    my $value = True but False;
#?rakudo todo "RT #121940 - should be 'True'"
    is $value, True, 'True but False';
    #?rakudo.jvm todo "RT #121940 - got 'True' instead of 'False'"
    is ?$value, False, 'True but False';
}
