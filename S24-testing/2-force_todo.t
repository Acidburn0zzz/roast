use v6.d;
use Test;

plan 11;

force_todo(1, 3, 5, 7 .. 9, 11);

flunk("This will fail, but will be forced-TODO by force_todo()");
pass("This will pass normally");
flunk("This will fail, but will be forced-TODO by force_todo()");
pass("This will pass normally");
flunk("This will TODO fail, and will be forced-TODO by force_todo()", :todo(1));
pass("This will pass normally");
flunk("This will fail, and will be forced-TODO by force_todo()");
flunk("This will fail, and will be forced-TODO by force_todo()");
flunk("This will fail, and will be forced-TODO by force_todo()");
pass("This will pass normally");
flunk("This will fail, and will be forced-TODO by force_todo()");

# vim: expandtab shiftwidth=4 ft=perl6
