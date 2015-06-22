use v6;

use Test;

plan 4;

ok($*PROGRAM ~~ / t['/'|'\\']spec['/'|'\\']S02'-'magicals['/'|'\\']progname'.'\w+$/, "progname var matches test file path");
ok(PROCESS::<$PROGRAM> ~~ / t['/'|'\\']spec['/'|'\\']S02'-'magicals['/'|'\\']progname'.'\w+$/, "progname var accessible as context var");

# NOTE:
# above is a junction hack for Unix and Win32 file
# paths until the FileSpec hack is working - Stevan
# changed junction hack in test 2 to regex for Rakudo fudged filename - mberends

#?niecza todo
lives-ok { my $*PROGRAM-NAME = "coldfusion" }, '$*PROGRAM-NAME is assignable';

# RT #113078
{
    use lib 't/spec/packages';
    use Test::Util;
    is_run 'print $*PROGRAM-NAME', {
        out => -> $x { $x !~~ /IGNOREME/ },
    },
    :compiler-args['-IGNOREME'],
    :args['IGNOREME'],
    '$*PROGRAM-NAME is not confused by compiler options';
}


# vim: ft=perl6
