use v6;
use Test;

#?niecza emit plan 8; #
plan 11;

# this test file contains tests for line numbers, among other things
# so it's extremely important not to randomly insert or delete lines.

my $baseline = 10;

isa-ok callframe(), CallFrame, 'callframe() returns a CallFrame';

sub f() {
    is callframe().line, $baseline + 4, 'callframe().line';
    ok callframe().file ~~ /« callframe »/, '.file';

    #?rakudo skip 'Unable to resolve method inline in type CallFrame'
    #?niecza skip 'Unable to resolve method inline in type CallFrame'
    nok callframe().inline, 'explicitly entered block (.inline)';

    # Note:  According to S02, these should probably fail unless
    # $x is marked 'is dynamic'.  We allow it for now since there's
    # still some uncertainty in the spec in S06, though.
    #?niecza skip 'Unable to resolve method my in type CallFrame'
    is callframe(1).my.<$x>, 42, 'can access outer lexicals via .my';
    #?niecza emit #
    callframe(1).my.<$x> = 23;

    #?niecza skip 'Unable to resolve method my in type CallFrame'
    is callframe(1).my.<$y>, 353, 'can access outer lexicals via .my';
    #?niecza emit #
    dies_ok { callframe(1).my.<$y> = 768 }, 'cannot mutate without is dynamic';;
}

my $x is dynamic = 42;
my $y = 353;

f();

#?niecza todo 'needs .my'
is $x,  23, '$x successfully modified';
is $y, 353, '$y not modified';

# RT #77752
is index(callframe.perl,"CallFrame.new("), 0, 'CallFrame.perl works';
# (Could probably be more readable, currently same as .perl)
is index(callframe.gist,"CallFrame.new("), 0, 'CallFrame.gist works';

done();

# vim: ft=perl6
