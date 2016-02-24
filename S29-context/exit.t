use v6.c;
use Test;

plan 3;

# L<S29/Context/"=item exit">

use lib 't/spec/packages';
use Test::Util;

is_run 'say 3; exit; say 5',
    { out => "3\n", err => "", status => 0 },
    'bare exit; works';

is_run 'say 3; exit 5; say 5',
    { out => "3\n", err => "", status => 5 +< 8 },
    'exit 5; works';

is_run 'say 3; try { exit 5 }; say 5',
    { out => "3\n", err => "", status => 5 +< 8 },
    'try-block does not catch exit exceptions';

# vim: ft=perl6
