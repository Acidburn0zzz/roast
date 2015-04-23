constant CHARS_TEST_CASES = 500;
constant NFC_ROUNDTRIP_TEST_CASES = 500;
constant OTHER_ROUNDTRIP_TEST_CASES = 100;
constant EQUALITY_TEST_CASES = 500;

sub MAIN(Str $unidata-normalization-tests) {
    # Parse the normalization test data, and gather those cases where the NFC
    # form contains a non-starter (Canonical_Combining_Class > 0).
    my @targets = my ($source, $nfc, $nfd, $nfkc, $nfkd) = [] xx 5;
    for $unidata-normalization-tests.IO.lines {
        next if /^['#'|'@'|\s+$]/;
        my @pieces = .split(';')[^5];
        my @nfc-codes = @pieces[1].split(' ').map({ :16($_) });
        next if @nfc-codes < 2;
        for @nfc-codes -> $code {
            if ccc($code) > 0 {
                .push(@pieces.shift) for @targets;
                last;
            }
        }
    }
    say "Found $source.elems() interesting cases for NFG tests.";

    # Write tests.
    write-chars-test-file('t/spec/S15-nfg/mass-chars.t', $source, $nfc, CHARS_TEST_CASES);
    write-roundtrip-test-file('t/spec/S15-nfg/mass-roundtrip-nfc.t', $source, $nfc, 'NFC', NFC_ROUNDTRIP_TEST_CASES);
    write-roundtrip-test-file('t/spec/S15-nfg/mass-roundtrip-nfd.t', $source, $nfd, 'NFD', OTHER_ROUNDTRIP_TEST_CASES);
    write-roundtrip-test-file('t/spec/S15-nfg/mass-roundtrip-nfkc.t', $source, $nfkc, 'NFKC', OTHER_ROUNDTRIP_TEST_CASES);
    write-roundtrip-test-file('t/spec/S15-nfg/mass-roundtrip-nfkd.t', $source, $nfkd, 'NFKD', OTHER_ROUNDTRIP_TEST_CASES);
    write-equality-test-file('t/spec/S15-nfg/mass-equality.t', $nfd, EQUALITY_TEST_CASES);
}

sub write-chars-test-file($target, @source, @nfc, $limit) {
    given open($target, :w) {
        .say: qq:to/HEADER/;
# Normal Form Grapheme .chars tests, generated from NormalizationTests.txt in
# the Unicode database by S15-nfg/test-gen.p6. Check that a string in NFG form
# gets the right number of characters.

use Test;

plan $limit;
HEADER

        for @source Z @nfc -> $source, $nfc {
            # The number of chars we expect is:
            #   - Number of codes minus number of non-starters if the test
            #     case begins with a starter
            #   - Number of codes minus number of non-starts plus one
            #     otherwise (to account for isolated non-starters).
            my @codes = $nfc.split(' ').map({ :16($_) });
            my $non-starters = +@codes.grep({ ccc($_) > 0 });
            my $chars = ccc(@codes[0]) == 0
                ?? @codes.elems - $non-starters
                !! 1 + @codes.elems - $non-starters;
            .say: "is Uni.new(&hexy($source)).Str.chars, $chars, '$source';";
            last if ++$ == $limit;
        }

        .close;
    }

    say "Wrote $target";
}

sub write-roundtrip-test-file($target, @source, @expected, $form, $limit) {
    given open($target, :w) {
        .say: qq:to/HEADER/;
# Normal Form Grapheme roundtrip tests, generated from NormalizationTests.txt in
# the Unicode database by S15-nfg/test-gen.p6. Check we can take a Uni, turn it
# into an NFG string, and then get codepoints back out of it in $form.

use Test;

plan $limit;
HEADER

        for @source Z @expected -> $source, $expected {
            next if $source eq $expected;
            .say: "ok Uni.new(&hexy($source)).Str.$form.list ~~ (&hexy($expected),), '$source -> Str -> $expected';";
            last if ++$ == $limit;
        }

        .close;
    }

    say "Wrote $target";
}

sub write-equality-test-file($target, @nfd, $limit) {
    given open($target, :w) {
        .say: qq:to/HEADER/;
# Normal Form Grapheme equanity tests, generated from NormalizationTests.txt in
# the Unicode database by S15-nfg/test-gen.p6. Check strings that should come
# out equal under NFG do, and strings that are "tempting" to make equal but
# should not be don't. The "should not be" falls out of the definition of NFD,
# of note the notion of blocked swaps in canonical sorting.

use Test;

plan $limit;
HEADER

        for @nfd -> $nfd {
            # Look for cases where we have two distinct non-starters in a row.
            my @codes = $nfd.split(' ').map({ :16($_) });
            my @swap  = @codes;
            my $test = 'is';
            loop (my $i = 0; $i < @codes - 1; $i++) {
                my $ccc1 = ccc(@codes[$i]);
                my $ccc2 = ccc(@codes[$i + 1]);
                if $ccc1 & $ccc2 > 0 && @codes[$i] != @codes[$i + 1] {
                    # Swap the two non-starters. If they have an equal ccc
                    # then they should test unequal.
                    @swap[$i, $i + 1] = @swap[$i + 1, $i];
                    $test = 'isnt' if $ccc1 == $ccc2;
                    $i++; # don't swap with next thing also
                }
            }
            my $hexy-swapped = @swap.map('0x' ~ *.base(16)).join(', ');
            my $hexy-nfd     = hexy($nfd);
            .say: "$test Uni.new($hexy-nfd).Str, Uni.new($hexy-swapped).Str, '$hexy-nfd vs. $hexy-swapped';";
            last if ++$ == $limit;
        }

        .close;
    }

    say "Wrote $target";
}

sub ccc($code) {
    uniprop($code, 'Canonical_Combining_Class')
}

sub hexy($codes) {
    $codes.split(' ').map('0x' ~ *).join(', ')
}
