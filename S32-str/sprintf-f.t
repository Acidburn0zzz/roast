use v6.e.PREVIEW;

#BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = True;
use Test;

# Test combinations of flags for "%f" and "%F".  The @info array is intialized
# with the flags (as a string), the size/precision specification (either a
# string or a # number), and the expected strings for the values 0, 1, 2.71
# and -2.71.  The flags values will be expanded to all possible permutations to
# ensure that the order of the flags is irrelevant.  Each flag permutation is
# combined with the size/permutation value to create a proper format string.
# Each test is done twice, once for "f" and once for "F".

#                         0 ,          1 ,       2.71 ,      -2.71 ;
my @info = ( # |------------|------------|------------|------------|
             # no size or size explicitely 0
       '',   '',  "0.000000",  "1.000000",  "2.710000", "-2.710000",
      ' ',   '', " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '0',   '',  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '0 ',   '', " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '+',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+ ',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+0',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
    '+0 ',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
      '-',   '',  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '-+',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '- ',   '', " 0.000000", " 1.000000", " 2.710000", "-2.710000",
    '-+ ',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '-0',   '',  "0.000000",  "1.000000",  "2.710000", "-2.710000",
    '-+0',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",
    '-0 ',   '', " 0.000000", " 1.000000", " 2.710000", "-2.710000",
   '-+0 ',   '', "+0.000000", "+1.000000", "+2.710000", "-2.710000",

             # no size, precision 0
       '', '.0',         "0",         "1",         "3",        "-3",
      ' ', '.0',        " 0",        " 1",        " 3",        "-3",
      '0', '.0',         "0",         "1",         "3",        "-3",
     '0 ', '.0',        " 0",        " 1",        " 3",        "-3",
      '+', '.0',        "+0",        "+1",        "+3",        "-3",
     '+ ', '.0',        "+0",        "+1",        "+3",        "-3",
     '+0', '.0',        "+0",        "+1",        "+3",        "-3",
    '+0 ', '.0',        "+0",        "+1",        "+3",        "-3",
      '-', '.0',         "0",         "1",         "3",        "-3",
     '-+', '.0',        "+0",        "+1",        "+3",        "-3",
     '- ', '.0',        " 0",        " 1",        " 3",        "-3",
    '-+ ', '.0',        "+0",        "+1",        "+3",        "-3",
     '-0', '.0',         "0",         "1",         "3",        "-3",
    '-+0', '.0',        "+0",        "+1",        "+3",        "-3",
    '-0 ', '.0',        " 0",        " 1",        " 3",        "-3",
   '-+0 ', '.0',        "+0",        "+1",        "+3",        "-3",

             # 2 positions, usually doesn't fit
       '',    2,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
      ' ',    2, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '0',    2,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '0 ',    2, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '+',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+ ',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+0',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
    '+0 ',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
      '-',    2,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '-+',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '- ',    2, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
    '-+ ',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '-0',    2,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
    '-0 ',    2, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
    '-+0',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
   '-+0 ',    2, "+0.000000", "+1.000000", "+2.710000", "-2.710000",

             # 8 positions, should always fit
       '',    8,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
      ' ',    8, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '0',    8,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '0 ',    8, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
      '+',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+ ',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '+0',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
    '+0 ',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
      '-',    8,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
     '-+',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '- ',    8, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
    '-+ ',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
     '-0',    8,  "0.000000",  "1.000000",  "2.710000", "-2.710000",
    '-0 ',    8, " 0.000000", " 1.000000", " 2.710000", "-2.710000",
    '-+0',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",
   '-+0 ',    8, "+0.000000", "+1.000000", "+2.710000", "-2.710000",

             # 8 positions with precision, precision fits sometimes
       '',  8.2,  "    0.00",  "    1.00",  "    2.71",  "   -2.71",
      ' ',  8.2,  "    0.00",  "    1.00",  "    2.71",  "   -2.71",
      '0',  8.2,  "00000.00",  "00001.00",  "00002.71",  "-0002.71",
     '0 ',  8.2,  " 0000.00",  " 0001.00",  " 0002.71",  "-0002.71",
      '+',  8.2,  "   +0.00",  "   +1.00",  "   +2.71",  "   -2.71",
     '+ ',  8.2,  "   +0.00",  "   +1.00",  "   +2.71",  "   -2.71",
     '+0',  8.2,  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
    '+0 ',  8.2,  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
      '-',  8.2,  "0.00    ",  "1.00    ",  "2.71    ",  "-2.71   ",
     '-+',  8.2,  "+0.00   ",  "+1.00   ",  "+2.71   ",  "-2.71   ",
     '- ',  8.2,  " 0.00   ",  " 1.00   ",  " 2.71   ",  "-2.71   ",
    '-+ ',  8.2,  "+0.00   ",  "+1.00   ",  "+2.71   ",  "-2.71   ",
# NOTE: all the ".xxx" are bogus, but provided by the current implementation
     '-0',  8.2,  "0000.000",  "0001.000",  "0002.710",  "-0002.71",
    '-+0',  8.2,  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
    '-0 ',  8.2,  " 0000.00",  " 0001.00",  " 0002.71",  "-0002.71",
   '-+0 ',  8.2,  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",

).map: -> $flags, $size, $r0, $r1, $r4, $rm {
    my @flat;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => 0, $r1 => 1, $r4 => 2.71, $rm => -2.71)
    ) for $flags.comb.permutations>>.join;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => 0, $r1 => 1, $r4 => 2.71, $rm => -2.71)
    ) for "#$flags".comb.permutations>>.join;
    |@flat
}

# tests using variable precision
@info.append( (
             # no size, precision 0
       '', '.*',         "0",         "1",         "3",        "-3",
      ' ', '.*',        " 0",        " 1",        " 3",        "-3",
      '0', '.*',         "0",         "1",         "3",        "-3",
     '0 ', '.*',        " 0",        " 1",        " 3",        "-3",
      '+', '.*',        "+0",        "+1",        "+3",        "-3",
     '+ ', '.*',        "+0",        "+1",        "+3",        "-3",
     '+0', '.*',        "+0",        "+1",        "+3",        "-3",
    '+0 ', '.*',        "+0",        "+1",        "+3",        "-3",
      '-', '.*',         "0",         "1",         "3",        "-3",
     '-+', '.*',        "+0",        "+1",        "+3",        "-3",
     '- ', '.*',        " 0",        " 1",        " 3",        "-3",
    '-+ ', '.*',        "+0",        "+1",        "+3",        "-3",
     '-0', '.*',         "0",         "1",         "3",        "-3",
    '-+0', '.*',        "+0",        "+1",        "+3",        "-3",
    '-0 ', '.*',        " 0",        " 1",        " 3",        "-3",
   '-+0 ', '.*',        "+0",        "+1",        "+3",        "-3",

).map: -> $flags, $size, $r0, $r1, $r4, $rm {
    my @flat;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => (0,0), $r1 => (0,1), $r4 => (0,2.71), $rm => (0,-2.71))
   ) for $flags.comb.permutations>>.join;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => (0,0), $r1 => (0,1), $r4 => (0,2.71), $rm => (0,-2.71))
   ) for "#$flags".comb.permutations>>.join;
   |@flat
} );

@info.append( (
             # 8 positions with precision, precision fits sometimes
       '', "8.*",  "    0.00",  "    1.00",  "    2.71",  "   -2.71",
      ' ', "8.*",  "    0.00",  "    1.00",  "    2.71",  "   -2.71",
      '0', "8.*",  "00000.00",  "00001.00",  "00002.71",  "-0002.71",
     '0 ', "8.*",  " 0000.00",  " 0001.00",  " 0002.71",  "-0002.71",
      '+', "8.*",  "   +0.00",  "   +1.00",  "   +2.71",  "   -2.71",
     '+ ', "8.*",  "   +0.00",  "   +1.00",  "   +2.71",  "   -2.71",
     '+0', "8.*",  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
    '+0 ', "8.*",  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
      '-', "8.*",  "0.00    ",  "1.00    ",  "2.71    ",  "-2.71   ",
     '-+', "8.*",  "+0.00   ",  "+1.00   ",  "+2.71   ",  "-2.71   ",
     '- ', "8.*",  " 0.00   ",  " 1.00   ",  " 2.71   ",  "-2.71   ",
    '-+ ', "8.*",  "+0.00   ",  "+1.00   ",  "+2.71   ",  "-2.71   ",
# NOTE: all the ".xxx" are bogus, but provided by the current implementation
     '-0', "8.*",  "0000.000",  "0001.000",  "0002.710",  "-0002.71",
    '-+0', "8.*",  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",
    '-0 ', "8.*",  " 0000.00",  " 0001.00",  " 0002.71",  "-0002.71",
   '-+0 ', "8.*",  "+0000.00",  "+0001.00",  "+0002.71",  "-0002.71",

).map: -> $flags, $size, $r0, $r1, $r4, $rm {
    my @flat;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => (2,0), $r1 => (2,1), $r4 => (2,2.71), $rm => (2,-2.71))
   ) for $flags.comb.permutations>>.join;
    @flat.append(
      '%' ~ $_ ~ $size ~ 'f',
      ($r0 => (2,0), $r1 => (2,1), $r4 => (2,2.71), $rm => (2,-2.71))
   ) for "#$flags".comb.permutations>>.join;
   |@flat
} );

plan @info/2;

for @info -> $format, @tests {
    subtest {
        plan 2 * @tests;

        for @tests {
            is-deeply sprintf($format, |.value), .key,
              qq/sprintf("$format",{.value.list.join(",")}) eq '{.key}'/;
            is-deeply sprintf($format.uc, |.value), .key.uc,
              qq/sprintf("{$format.uc}",{.value.list.join(",")}) eq '{.key.uc}'/;
        }
    }, "Tested '$format'";
}

# vim: ft=perl6
