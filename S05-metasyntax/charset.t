use v6;

use Test;

=begin pod

This file was derived from the perl5 CPAN module Perl6::Rules,
version 0.3 (12 Apr 2004), file t/charset.t.

It has (hopefully) been, and should continue to be, updated to
be valid perl6.

=end pod

plan 41;

# Broken:
# L<S05/Extensible metasyntax (C<< <...> >>)/"A leading [ ">

ok("zyxaxyz" ~~ m/(<[aeiou]>)/, 'Simple set');
is($0, 'a', 'Simple set capture');

# L<S05/Extensible metasyntax (C<< <...> >>)/"A leading - indicates">
ok(!( "a" ~~ m/<-[aeiou]>/ ), 'Simple neg set failure');
ok("f" ~~ m/(<-[aeiou]>)/, 'Simple neg set match');
is($0, 'f', 'Simple neg set capture');

# L<S05/Extensible metasyntax (C<< <...> >>)/Character classes can be combined>
ok(!( "a" ~~ m/(<[a..z]-[aeiou]>)/ ), 'Difference set failure');
ok("y" ~~ m/(<[a..z]-[aeiou]>)/, 'Difference set match');
is($0, 'y', 'Difference set capture');

# RT #115802
ok(  "abc" ~~ m/<[\w]-[\n]>/,  'Difference set match 1');
ok(!("abc" ~~ m/<[\w]-[\N]>/), 'Difference set match 2');
is(("abc123" ~~ m/<[\w]-[a\d]>+/), 'bc', 'Difference set match 3');
is(("abc123" ~~ m/<[\w]-[1\D]>+/), '23', 'Difference set match 4');
#?niecza todo 'gives c123?'
is(("abc123def" ~~ m/<[\w]-[\D\n]>+/), '123', 'Difference set match 5');
is(("abc123def" ~~ m/<[\w]-[\D\h]>+/), '123', 'Difference set match 6');
is(("abc" ~~ /<-["\\\t\n]>+/), 'abc', 'Difference set match 7');

ok(!( "a" ~~ m/(<+alpha-[aeiou]>)/ ), 'Named difference set failure');
ok("y" ~~ m/(<+alpha-[aeiou]>)/, 'Named difference set match');
is($0, 'y', 'Named difference set capture');
ok(!( "y" ~~ m/(<[a..z]-[aeiou]-[y]>)/ ), 'Multi-difference set failure');
ok("f" ~~ m/(<[a..z]-[aeiou]-[y]>)/, 'Multi-difference set match');
is($0, 'f', 'Multi-difference set capture');

ok(']' ~~ m/(<[\]]>)/, 'quoted close LSB match');
is($0, ']', 'quoted close LSB capture');
ok('[' ~~ m/(<[\[]>)/, 'quoted open LSB match');
is($0, '[', 'quoted open LSB capture');
ok('{' ~~ m/(<[\{]>)/, 'quoted open LCB match');
is($0, '{', 'quoted open LCB capture');
ok('}' ~~ m/(<[\}]>)/, 'quoted close LCB match');
is($0, '}', 'quoted close LCB capture');

# RT #67124
eval-lives-ok( '"foo" ~~ /<[f] #`[comment] + [o]>/',
               'comment embedded in charset can be parsed' );
ok( "foo" ~~ /<[f] #`[comment] + [o]>/, 'comment embedded in charset works' );

# RT #67122
ok "\x[FFEF]" ~~ /<[\x0..\xFFEF]>/, 'large \\x char spec';

#?niecza todo
eval-dies-ok( "'RT 71702' ~~ /<[d..b]>? RT/",
    'reverse range in charset is lethal (RT 71702)' );

# RT #64220
ok 'b' ~~ /<[. .. b]>/, 'weird char class matches at least its end point';

# RT #69682
{
try { EVAL "/<[a-z]>/"; }
ok ~$! ~~ / 'Unsupported use of - as character range; in Perl 6 please use ..'/,
    "STD error message for - as character range";
}

ok 'ab' ~~ /^(.*) b/,
    'Quantifiers in capture groups work (RT 100650)';

# RT #74012
# backslashed characters in char classes
ok '[]\\' ~~ /^ <[ \[ .. \] ]>+ $ /, 'backslashed chars in char classes';
nok '^'   ~~ /  <[ \[ .. \] ]>    /, '... does not match outside its range';

# RT #89470
{
    nok  '' ~~ / <[a..z]-[x]> /, 'Can match empty string against char class';
    nok 'x' ~~ / <[a..z]-[x]> /, 'char excluded from class';
     ok 'z' ~~ / <[a..z]-[x]> /, '... but others are fine';
}

# vim: ft=perl6
