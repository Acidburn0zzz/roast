use v6;
use Test;
plan 22;

# L<S02/Names and Variables/so that Perl can evaluate the result
# back to the same object>

my @tests = (

    # References to aggregates
    [],
    [ 42 ],  # only one elem
    [< a b c>],
    [ 3..42 ],

    # XXX Actually skip these instead of commenting them out.
    # [ 3..Inf ],
    # [ -Inf..Inf ],
    # [ 3..42, 17..Inf, -Inf..5 ],

    # Nested arrays
    [      [1,2,3] ],  # only one elem
    [[2,3],4,[6,8]], # three elems
);

{
    for @tests -> $obj {
        my $s = (~$obj).subst(/\n/, '␤');
        ok EVAL($obj.perl) eq $obj,
            "($s.perl()).perl returned something whose EVAL()ed stringification is unchanged";
        is (EVAL($obj.perl).WHAT).gist, $obj.WHAT.gist,
            "($s.perl()).perl returned something whose EVAL()ed .WHAT is unchanged";
    }
}

# Recursive data structures
#?rakudo skip 'recursive data structure RT #124639'
{
    my $foo = [ 42 ]; $foo[1] = $foo;
    is $foo[1][1][1][0], 42, "basic recursive arrayref";

    #?niecza skip 'hanging test'
    is ~$foo.perl.EVAL, ~$foo,
        ".perl worked correctly on a recursive arrayref";
}

{
    # test bug in .perl on result of hyperoperator
    # first the trivial case without hyperop
    my @foo = ([-1, -2], -3);
    is @foo.item.perl, '[[-1, -2], -3]', ".perl on a nested list";

    my @hyp = -« ([1, 2], 3);
    # what it currently (r16460) gives
    isnt @hyp.item.perl, '[(-1, -2), -3]', "strange inner parens from .perl on result of hyperop";

    # what it should give
    is @hyp.item.perl, '[[-1, -2], -3]', ".perl on a nested list result of hyper operator";
}

{
    # beware: S02 says that .perl should evaluate the invocant in item
    # context, so EVAL @thing.perl returns a scalar. Always.

    # L<S02/Names and Variables/regenerate the object as a scalar in
    # item context>


    my @list = (1, 2);
    push @list, EVAL (3, 4).perl;
    #?rakudo todo "List.perl bug"
    #?niecza todo
    is +@list, 3, 'EVAL(@list.perl) gives a list, not an array ref';
}

# RT #63724
{
    my @original      = (1,2,3);
    my $dehydrated    = @original.perl;
    my @reconstituted = @( EVAL $dehydrated );

    is @reconstituted, @original,
       "EVAL of .perl returns original for '$dehydrated'";

    @original      = (1,);
    $dehydrated    = @original.perl;
    @reconstituted = @( EVAL $dehydrated );

    is @reconstituted, @original,
       "EVAL of .perl returns original for '$dehydrated'";
}

# RT #65988
{
    my $rt65988 = (\(1,2), \(3,4));
    is_deeply EVAL( $rt65988.perl ), $rt65988, $rt65988.perl ~ '.perl';
}

# probably there is a better place for this test
# RT #117481
{
    my %count;
    for ('/foo/bar/baz/' ~~ m/^ $<dirname>=(.* '/'+)? $<basename>=(<-[\/]>+) '/'* $ /).gist.lines {
        %count{$0}++ if / ^ \s+ (\w+) \s+ '=>' /;   ## extract key
    };
    is (%count<basename>, %count<dirname>), (1, 1),
        'no duplicate keys in .gist of Match of regex which backtracked';
}

done;

# vim: ft=perl6

