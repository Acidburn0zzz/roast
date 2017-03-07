use v6.c;
use Test;

my @endings =
  "\n"               => "LF",
  "\r"               => "CR",
  ";"                => "semi-colon",
  ":\n:"             => "colons",
  ("\n","\r\n","\r") => "multi",
;

## adjusted plan to allow fine grained fudging for rakudo.jvm
#plan @endings * (1 + 3 * ( (3 * 5) + 6));
my $extra_tests_jvm_fudging = 2 * 3 * ( 3 * ( 6 + 2 ) );
plan @endings * (1 + 3 * ( 5 + 6)) + $extra_tests_jvm_fudging;

my $filename = 't/spec/S16-io/lines.testing';
my @text = <zero one two three four>;

for @endings -> (:key($eol), :value($EOL)) {
    unlink $filename;  # make sure spurt will work

    my $text = @text.join($eol[0]);
    ok $filename.IO.spurt($text), "could we spurt a file with $EOL";

    for (), '', :chomp, '', :!chomp, $eol -> $chomp, $end {
        my $status = "{$chomp.gist} / $EOL";

        my $handle = open($filename, :nl-in($eol), |$chomp);
        isa-ok $handle, IO::Handle;

        my $first;
        for $handle.lines -> $line {
            #?rakudo.jvm skip 'test will be run below with fine grained fudging'
            is $line,"@text[0]$end[0]", "read first line: $status";
            $first = $line;
            last;
        }

        my @lines = $first, |$handle.lines;
        #?rakudo.jvm skip 'test will be run below with fine grained fudging'
        is @lines.join, @text.join($end[0]), "rest of file: $status";

        ok $handle.opened, "handle still open";
        ok $handle.close, "closed handle";

        # slicing
        my $handle = open($filename, :nl-in($eol), |$chomp);
        isa-ok $handle, IO::Handle;

        my @lines = $handle.lines[1,2];
        #?rakudo.jvm skip 'test will be run below with fine grained fudging'
        is @lines.join, @text[1,2].join($end[0]) ~ $end[0],
          "handle 1,2: $status";

        is $handle.lines[*-1], @text[*-1], "handle last line: $status";

        $handle.close;

        # slicing on IO::Path
        #?rakudo.jvm skip 'test will be run below with fine grained fudging'
        is $filename.IO.lines(:nl-in($eol), |$chomp)[1,2,*-1][^2].join($end[0]),
          @text[1,2].map({ $_ ~ $end[0] }).join($end[0]),
          "path 1,2: $status";

        is $filename.IO.lines(:nl-in($eol), |$chomp)[*-1],
          @text[*-1],
          "path last line: $status";

        is $filename.IO.lines(:nl-in($eol), |$chomp).elems,
          +@text,
          "path elems: $status";
    }
}

## run those tests that are skipped above for rakudo.jvm
## note: all tests below are skipped for rakudo.moar since they already run above
##
## TODO once the tests below pass on rakudo.jvm
## * remove the two top level blocks below (keep unlink at end of file)
## * unfudge tests in first 'for' loop
## * adjust plan accordingly

## the following tests pass on rakudo.jvm
{
    my @endings_jvm_passing =
      "\n"               => "LF",
      "\r\n"             => "CRLF",
      ("\n","\r\n","\r") => "multi",
    ;

    for @endings_jvm_passing -> (:key($eol), :value($EOL)) {
        unlink $filename;  # make sure spurt will work

        my $text = @text.join($eol[0]);
        $filename.IO.spurt($text);

        for (), '', :chomp, '', :!chomp, $eol -> $chomp, $end {
            my $status = "{$chomp.gist} / $EOL";

            for (), True, :close, False, :!close, True -> $closing, $open {
                my $handle = open($filename, :nl-in($eol), |$chomp);

                my $status = OUTER::<$status> ~ " / {$open ?? 'open' !! 'close'}";

                my $first;
                for $handle.lines(|$closing) -> $line {
                    #?rakudo.moar skip 'tests are already executed above'
                    is $line,"@text[0]$end[0]", "read first line: $status";
                    $first = $line;
                    last;
                }

                my @lines = $first, |$handle.lines(|$closing);
                #?rakudo.moar skip 'tests are already executed above'
                is @lines.join, @text.join($end[0]), "rest of file: $status";

                $handle.close;
            }

            # slicing
            my $handle = open($filename, :nl-in($eol), |$chomp);

            my @lines = $handle.lines[1,2];
            #?rakudo.moar skip 'tests are already executed above'
            is @lines.join, @text[1,2].join($end[0]) ~ $end[0],
              "handle 1,2: $status";

            $handle.close;

            # slicing on IO::Path
            #?rakudo.moar skip 'tests are already executed above'
            is $filename.IO.lines(:nl-in($eol), |$chomp)[1,2,*-1][^2].join($end[0]),
              @text[1,2].map({ $_ ~ $end[0] }).join($end[0]),
              "path 1,2: $status";
        }
    }
}

## some of the following tests need to be fudged for rakudo.jvm
{
    my @endings_jvm_fudging =
      "\r"               => "CR",
      ";"                => "semi-colon",
      ":\n:"             => "colons",
    ;

    for @endings_jvm_fudging -> (:key($eol), :value($EOL)) {
        unlink $filename;  # make sure spurt will work

        my $text = @text.join($eol[0]);
        $filename.IO.spurt($text);

        ## the following tests pass on rakudo.jvm
        for :!chomp, $eol -> $chomp, $end {
            my $status = "{$chomp.gist} / $EOL";

            for (), True, :close, False, :!close, True -> $closing, $open {
                my $handle = open($filename, :nl-in($eol), |$chomp);

                my $status = OUTER::<$status> ~ " / {$open ?? 'open' !! 'close'}";

                my $first;
                for $handle.lines(|$closing) -> $line {
                    #?rakudo.moar skip 'tests are already executed above'
                    is $line,"@text[0]$end[0]", "read first line: $status";
                    $first = $line;
                    last;
                }

                my @lines = $first, |$handle.lines(|$closing);
                #?rakudo.moar skip 'tests are already executed above'
                is @lines.join, @text.join($end[0]), "rest of file: $status";

                $handle.close;
            }

            # slicing
            my $handle = open($filename, :nl-in($eol), |$chomp);

            my @lines = $handle.lines[1,2];
            #?rakudo.moar skip 'tests are already executed above'
            is @lines.join, @text[1,2].join($end[0]) ~ $end[0],
              "handle 1,2: $status";

            $handle.close;

            # slicing on IO::Path
            #?rakudo.moar skip 'tests are already executed above'
            is $filename.IO.lines(:nl-in($eol), |$chomp)[1,2,*-1][^2].join($end[0]),
              @text[1,2].map({ $_ ~ $end[0] }).join($end[0]),
              "path 1,2: $status";
        }

        ## the following tests do not yet pass on rakudo.jvm
        for (), '', :chomp, ''  -> $chomp, $end {
            my $status = "{$chomp.gist} / $EOL";

            for (), True, :close, False, :!close, True -> $closing, $open {
                my $handle = open($filename, :nl-in($eol), |$chomp);

                my $status = OUTER::<$status> ~ " / {$open ?? 'open' !! 'close'}";

                my $first;
                for $handle.lines(|$closing) -> $line {
                    #?rakudo.moar skip 'tests are already executed above'
                    #?rakudo.jvm todo ':nl-in and :chomp not working yet'
                    is $line,"@text[0]$end[0]", "read first line: $status";
                    $first = $line;
                    last;
                }

                my @lines = $first, |$handle.lines(|$closing);
                #?rakudo.moar skip 'tests are already executed above'
                #?rakudo.jvm todo ':nl-in and :chomp not working yet'
                is @lines.join, @text.join($end[0]), "rest of file: $status";

                $handle.close;
            }

            # slicing
            my $handle = open($filename, :nl-in($eol), |$chomp);

            my @lines = $handle.lines[1,2];
            #?rakudo.moar skip 'tests are already executed above'
            #?rakudo.jvm todo ':nl-in and :chomp not working yet'
            is @lines.join, @text[1,2].join($end[0]) ~ $end[0],
              "handle 1,2: $status";

            $handle.close;

            # slicing on IO::Path
            #?rakudo.moar skip 'tests are already executed above'
            #?rakudo.jvm todo ':nl-in and :chomp not working yet'
            is $filename.IO.lines(:nl-in($eol), |$chomp)[1,2,*-1][^2].join($end[0]),
              @text[1,2].map({ $_ ~ $end[0] }).join($end[0]),
              "path 1,2: $status";
        }
    }
}

unlink $filename; # cleanup

# vim: ft=perl6
