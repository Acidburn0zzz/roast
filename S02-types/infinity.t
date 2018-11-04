use v6;
use lib $?FILE.IO.parent(2).add: 'packages/Test-Helpers';
use Test;
use Test::Util;
plan 21;

# L<S02/"Infinity and C<NaN>" /Perl 6 by default makes standard IEEE floating point concepts visible>

{
    my $x = Inf;

    ok( $x == Inf  , 'numeric equal');
    ok( $x eq 'Inf', 'string equal');
}

{
    my $x = -Inf;
    ok( $x == -Inf,   'negative numeric equal' );
    ok( $x eq '-Inf', 'negative string equal' );
}

#?rakudo skip 'integer Inf RT #124451'
{
    my $x = Inf.Int;
    ok( $x == Inf,   'int numeric equal' );
    ok( $x eq 'Inf', 'int string equal' );
}

#?rakudo skip 'integer Inf RT #124452'
{
    my $x = ( -Inf ).Int;
    ok( $x == -Inf,   'int numeric equal' );
    ok( $x eq '-Inf', 'int string equal' );
}

# Inf should == Inf. Additionally, Inf's stringification (~Inf), "Inf", should
# eq to the stringification of other Infs.
# Thus:
#     Inf == Inf     # true
# and:
#     Inf  eq  Inf   # same as
#     ~Inf eq ~Inf   # true

ok truncate(Inf) ~~ Inf,    'truncate(Inf) ~~ Inf';

# RT #124453
{
    fails-like {    Inf.Int }, X::Numeric::CannotConvert,
        'attempting to convert Inf to Int throws';

    fails-like { (-Inf).Int }, X::Numeric::CannotConvert,
        'attempting to convert Inf to Int throws';

    fails-like {      ∞.Int }, X::Numeric::CannotConvert,
        'attempting to convert ∞ to Int throws';

    fails-like {   (-∞).Int }, X::Numeric::CannotConvert,
        'attempting to convert -∞ to Int throws';

    fails-like {    NaN.Int }, X::Numeric::CannotConvert,
        'attempting to convert NaN to Int throws';
}

# RT #70730
{
    ok ( rand * Inf ) === Inf, 'multiply rand by Inf without maximum recursion depth exceeded';
}

{
    #RT #126990
    throws-like ｢my Int $x = Inf｣, X::Syntax::Number::LiteralType,
        :value(Inf), :vartype(Int),
    'trying to assign Inf to Int gives a helpful error';

    my Num $x = Inf;
    is $x, Inf, 'assigning Inf to Num works without errors';
}

{ # RT #129915
    is-deeply -Inf², -Inf, '-Inf² follows mathematical order of operations';
    is-deeply -∞², -Inf, '-∞² follows mathematical order of operations';
    is-deeply −Inf², -Inf,
        '−Inf² follows mathematical order of operations (U+2212 minus)';
    is-deeply −∞², -Inf,
        '−∞² follows mathematical order of operations (U+2212 minus)';
}

# vim: ft=perl6
