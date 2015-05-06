use v6;

use Test;

plan 37;

=begin description

This test tests the C<squish> builtin and .squish method on Any/List.

=end description

#?niecza skip 'NYI'
{
    my @array = <a b b c d e f f a>;
    is_deeply @array.squish,  <a b c d e f a>.list.item,
      "method form of squish works";
    is_deeply squish(@array), <a b c d e f a>.list.item,
      "subroutine form of squish works";
    is_deeply @array .= squish, [<a b c d e f a>],
      "inplace form of squish works";
    is_deeply @array, [<a b c d e f a>],
      "final result of in place";
} #4

{
    is_deeply squish(Any,'a', 'b', 'b', 'c', 'd', 'e', 'f', 'f', 'a'),
      (Any, <a b c d e f a>.list).list.item,
      'slurpy subroutine form of squish works';
} #1

#?niecza skip 'NYI'
{
    is 42.squish, 42,    ".squish can work on scalars";
    is (42,).squish, 42, ".squish can work on one-elem arrays";
} #2

#?niecza skip 'NYI'
{
    my class A { method Str { '' } };
    is (A.new, A.new).squish.elems, 2, 'squish has === semantics for objects';
} #1

#?niecza skip 'NYI'
{
    my @list = 1, "1";
    my @squish = squish(@list);
    is @squish, @list, "squish has === semantics for containers";
} #1

#?niecza skip 'NYI'
{
    my @a := squish( 1..Inf );
    is @a[3], 4, "make sure squish is lazy";
} #1

#?niecza skip 'NYI'
{
    my @array = <a b bb c d e f f a>;
    my $as    = *.substr: 0,1;
    is_deeply @array.squish(:$as),  <a b c d e f a>.list.item,
      "method form of squish with :as works";
    is_deeply squish(@array,:$as), <a b c d e f a>.list.item,
      "subroutine form of squish with :as works";
    is_deeply @array .= squish(:$as), [<a b c d e f a>],
      "inplace form of squish with :as works";
    is_deeply @array, [<a b c d e f a>],
      "final result with :as in place";
} #4

#?niecza skip 'NYI'
{
    my @rt124204 = ('', '', Any, Any);
    #?rakudo todo 'RT #124204'
    is_deeply @rt124204.squish(:as(-> $x {$x})), ('', Any).list.item,
      "method form of squish with :as does not needlessly stringify";
    is_deeply @rt124204.squish, ('', Any).list.item,
      "method form of squish without :as does not needlessly stringify";
    #?rakudo todo 'RT #124204'
    is_deeply @rt124204.squish(:as(-> $x {$x}), :with({$^b === $^a})), ('', Any).list.item,
      "method form of squish with :as and :with does not needlessly stringify";
    is_deeply @rt124204.squish(:with({$^b === $^a})), ('', Any).list.item,
      "method form of squish with :with does not needlessly stringify";
} #4

#?niecza skip 'NYI'
#?rakudo todo 'RT #124205'
{
    my @rt124205 = <a a>;

    is_deeply @rt124205.squish(:as(-> $x {1}), :with(-> $a, $b {1})), <a>.list.item,
      "method form of squish with :as and :with always returns at least the first element";
    is_deeply @rt124205.squish(:with(-> $a, $b {1})), <a>.list.item,
      "method form of squish with :with always returns at least the first element";

    # somewhat more real-world examples:

    my @rt124205_b = '', '', <b b B B>;

    is_deeply @rt124205_b.squish(:with(*.Str eq *.Str)), ('', 'b', 'B').list.item,
      "method form of squish with :with preserves the first element even if it stringifies to ''";

    is_deeply @rt124205_b.squish(:as(*.Str), :with(&infix:<eq>)), ('', 'b', 'B').list.item,
      "method form of squish with :as and :with preserves the first element even if it stringifies to ''";

} #4

#?niecza skip 'NYI'
{
    my @array = <a aa b bb c d e f f a>;
    my $with  = { substr($^a,0,1) eq substr($^b,0,1) }
    is_deeply @array.squish(:$with),  <a b c d e f a>.list.item,
      "method form of squish with :with works";
    is_deeply squish(@array,:$with), <a b c d e f a>.list.item,
      "subroutine form of squish with :with works";
    is_deeply @array .= squish(:$with), [<a b c d e f a>],
      "inplace form of squish with :with works";
    is_deeply @array, [<a b c d e f a>],
      "final result with :with in place";
} #4

#?niecza skip 'NYI'
{
    my @array = <a aa b bb c d e f f a>;
    my $as    = *.substr(0,1).ord;
    my $with  = &[==];
    is_deeply @array.squish(:$as, :$with),  <a b c d e f a>.list.item,
      "method form of squish with :as and :with works";
    is_deeply squish(@array,:$as, :$with), <a b c d e f a>.list.item,
      "subroutine form of squish with :as and :with works";
    is_deeply @array .= squish(:$as, :$with), [<a b c d e f a>],
      "inplace form of squish with :as and :with works";
    is_deeply @array, [<a b c d e f a>],
      "final result with :as and :with in place";
} #4

#?niecza skip 'NYI'
{
    my @array = ({:a<1>}, {:a<1>}, {:b<1>});
    my $with  = &[eqv];
    is_deeply @array.squish(:$with),  ({:a<1>}, {:b<1>}).list.item,
      "method form of squish with [eqv] and objects works";
    is_deeply squish(@array,:$with), ({:a<1>}, {:b<1>}).list.item,
      "subroutine form of squish with [eqv] and objects works";
    is_deeply @array .= squish(:$with), [{:a<1>}, {:b<1>}],
      "inplace form of squish with [eqv] and objects works";
    is_deeply @array, [{:a<1>}, {:b<1>}],
      "final result with [eqv] and objects in place";
} #4

# RT #121434
{
    my $a = <a b b c>;
    $a .= squish;
    is_deeply( $a, <a b c>.list.item, '.= squish in sink context works on $a' );
    my @a = <a b b c>;
    @a .= squish;
    is_deeply( @a, [<a b c>], '.= squish in sink context works on @a' );
} #2

is ((3,3,1),(1,2),(1,2)).squish, '3 3 1 1 2', ".squish doesn't flatten";
# vim: ft=perl6
