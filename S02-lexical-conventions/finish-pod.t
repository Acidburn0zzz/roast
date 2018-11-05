use v6.d;

# Test various forms of comments

use Test;

plan 2;

# L<S02/Double-underscore forms/"The double-underscore forms are going away:">

ok 1, "Before the =finish Block";

is $=finish,q:to/TEXT/, 'can read the lines after =finish';
flunk "=finish cannot work properly";

# vim: ft=perl6
TEXT

=finish
flunk "=finish cannot work properly";

# vim: ft=perl6
