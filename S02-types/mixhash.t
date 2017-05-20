use v6.c;
use Test;

plan 229;

# L<S02/Mutable types/QuantHash of UInt>

# A MixHash is a QuantHash of UInt, i.e. the values are positive Int

sub showkv($x) {
    $x.keys.sort.map({"$_:{$x{$_}}"}).join(' ')
}

# L<S02/Immutable types/'the mix listop'>

{
    say "We do get here, right?";
    my $m = MixHash.new("a", "foo", "a", "a", "a", "a", "b", "foo");
    isa-ok $m, MixHash, 'we got a MixHash';
    is showkv($m), 'a:5 b:1 foo:2', '...with the right elements';

    is $m.default, 0, "Defaults to 0";
    is $m<a>, 5, 'Single-key subscript (existing element)';
    isa-ok $m<a>, Int, 'Single-key subscript yields an Int';
    is $m<santa>, 0, 'Single-key subscript (nonexistent element)';
    isa-ok $m<santa>, Int, 'Single-key subscript yields an Int (nonexistent element)';
    ok $m<a>:exists, 'exists with existing element';
    nok $m<santa>:exists, 'exists with nonexistent element';

    is $m.values.elems, 3, "Values returns the correct number of values";
    is ([+] $m.values), 8, "Values returns the correct sum";
    ok ?$m, "Bool returns True if there is something in the MixHash";
    nok ?MixHash.new(), "Bool returns False if there is nothing in the MixHash";
    
    my $hash;
    lives-ok { $hash = $m.hash }, ".hash doesn't die";
    isa-ok $hash, Hash, "...and it returned a Hash";
    is showkv($hash), 'a:5 b:1 foo:2', '...with the right elements';

    throws-like { $m.keys = <c d> },
      X::Assignment::RO,
      "Can't assign to .keys";
    throws-like { $m.values = 3, 4 },
      X::Assignment::RO,
      "Can't assign to .values";

    is ~$m<a b>, "5 1", 'Multiple-element access';
    is ~$m<a santa b easterbunny>, "5 0 1 0", 'Multiple-element access (with nonexistent elements)';

    #?niecza skip '.total NYI'
    is $m.total, 8, '.total gives sum of values';
    is $m.elems, 3, '.total gives sum of values';
    is +$m, 8, '+$mix gives sum of values';

    lives-ok { $m<a> = 42 }, "Can assign to an existing element";
    is $m<a>, 42, "... and assignment takes effect";
    lives-ok { $m<brady> = 12 }, "Can assign to a new element";
    is $m<brady>, 12, "... and assignment takes effect";
    lives-ok { $m<spiderman> = 0 }, "Can assign zero to a nonexistent element";
    nok $m<spiderman>:exists, "... and that didn't create the element";
    lives-ok { $m<brady> = 0 }, "Can assign zero to a existing element";
    nok $m<brady>:exists, "... and it goes away";
    
    lives-ok { $m<a>++ }, "Can ++ an existing element";
    is $m<a>, 43, "... and the increment happens";
    lives-ok { $m<carter>++ }, "Can ++ a new element";
    is $m<carter>, 1, "... and the element is created";
    lives-ok { $m<a>-- }, "Can -- an existing element";
    is $m<a>, 42, "... and the decrement happens";
    lives-ok { $m<carter>-- }, "Can -- an element with value 1";
    nok $m<carter>:exists, "... and it goes away";
    #?niecza todo
    lives-ok { $m<farve>-- }, "Can -- an element that doesn't exist";
    ok $m<farve>:exists, "... and everything is still okay";
}

{
    ok (MixHash.new: <a b c>) ~~ (MixHash.new: <a b c>), "Identical mixs smartmatch with each other";
    ok (MixHash.new: <a b c c>) ~~ (MixHash.new: <a b c c>), "Identical mixs smartmatch with each other";
    nok (MixHash.new: <b c>) ~~ (MixHash.new: <a b c>), "Subset does not smartmatch";
    nok (MixHash.new: <a b c>) ~~ (MixHash.new: <a b c c>), "Subset (only quantity different) does not smartmatch";
    nok (MixHash.new: <a b c d>) ~~ (MixHash.new: <a b c>), "Superset does not smartmatch";
    nok (MixHash.new: <a b c c c>) ~~ (MixHash.new: <a b c c>), "Superset (only quantity different) does not smartmatch";
    nok "a" ~~ (MixHash.new: <a b c>), "Smartmatch is not element of";
    ok (MixHash.new: <a b c>) ~~ MixHash, "Type-checking smartmatch works";

    ok (set <a b c>) ~~ (MixHash.new: <a b c>), "Set smartmatches with equivalent MixHash.new:";
    nok (set <a a a b c>) ~~ (MixHash.new: <a a a b c>), "... but not if the Mix has greater quantities";
    nok (set <a b c>) ~~ MixHash, "Type-checking smartmatch works";
}

{
    isa-ok "a".MixHash, MixHash, "Str.MixHash makes a MixHash";
    is showkv("a".MixHash), 'a:1', "'a'.MixHash is mix a";

    isa-ok (a => 100000).MixHash, MixHash, "Pair.MixHash makes a MixHash";
    is showkv((a => 100000).MixHash), 'a:100000', "(a => 100000).MixHash is mix a:100000";
    is showkv((a => 0).MixHash), '', "(a => 0).MixHash is the empty mix";

    isa-ok <a b c>.MixHash, MixHash, "<a b c>.MixHash makes a MixHash";
    is showkv(<a b c a>.MixHash), 'a:2 b:1 c:1', "<a b c a>.MixHash makes the mix a:2 b:1 c:1";
    is showkv(["a", "b", "c", "a"].MixHash), 'a:2 b:1 c:1', "[a b c a].MixHash makes the mix a:2 b:1 c:1";
    is showkv([a => 3, b => 0, 'c', 'a'].MixHash), 'a:4 c:1', "[a => 3, b => 0, 'c', 'a'].MixHash makes the mix a:4 c:1";

    isa-ok {a => 2, b => 4, c => 0}.MixHash, MixHash, "{a => 2, b => 4, c => 0}.MixHash makes a MixHash";
    is showkv({a => 2, b => 4, c => 0}.MixHash), 'a:2 b:4', "{a => 2, b => 4, c => 0}.MixHash makes the mix a:2 b:4";
}

{
    my $m = MixHash.new(<a a b foo>);
    is $m<a>:exists, True, ':exists with existing element';
    is $m<santa>:exists, False, ':exists with nonexistent element';
    is $m<a>:delete, 2, ':delete works on MixHash';
    is showkv($m), 'b:1 foo:1', '...and actually deletes';
}

{
    my $m = MixHash.new('a', False, 2, 'a', False, False);
    my @ks = $m.keys;
    #?niecza 3 skip "Non-Str keys NYI"
    is @ks.grep({ .WHAT === Int })[0], 2, 'Int keys are left as Ints';
    is @ks.grep(* eqv False).elems, 1, 'Bool keys are left as Bools';
    is @ks.grep(Str)[0], 'a', 'And Str keys are permitted in the same set';
    is $m{2, 'a', False}.join(' '), '1 2 3', 'All keys have the right values';
}

{
    my $a = (1,2,3,2,2,2,2).MixHash;
    is $a.kv.sort, (1,1,1,2,3,5), "MixHash.kv returns list of keys and values";
}

{
    my $m = MixHash.new(<a b o p a p o o>);
    isa-ok $m, MixHash, '&MixHash.new given an array of strings produces a MixHash';
    is showkv($m), 'a:2 b:1 o:3 p:2', '...with the right elements';
}

{
    my $m = MixHash.new([ foo => 10.1, bar => 17.2, baz => 42.3, santa => 0 ]);
    isa-ok $m, MixHash, '&MixHash.new given an array of pairs produces a MixHash';
    is $m.total, 4, 'make sure .total is ok';
    is $m.elems, 4, 'make sure .elems is ok';
}

{
    my $m = MixHash.new({ foo => 10, bar => 17, baz => 42, santa => 0 }.hash);
    isa-ok $m, MixHash, '&MixHash.new given a Hash produces a MixHash';
    is +$m, 4, "... with four elements";
    #?niecza todo "Non-string mix elements NYI"
    is +$m.grep(Pair), 4, "... which are all Pairs";
}

{
    my $m = MixHash.new({ foo => 10, bar => 17, baz => 42, santa => 0 });
    isa-ok $m, MixHash, '&MixHash.new given a Hash produces a MixHash';
    is +$m, 4, "... with four elements";
}

{
    my $m = MixHash.new(set <foo bar foo bar baz foo>);
    isa-ok $m, MixHash, '&MixHash.new given a Set produces a MixHash';
    is +$m, 1, "... with one element";
}

{
    my $m = MixHash.new(MixHash.new(<foo bar foo bar baz foo>));
    isa-ok $m, MixHash, '&MixHash.new given a MixHash produces a MixHash';
    is +$m, 1, "... with one element";
}

{
    my $m = MixHash.new(mix <foo bar foo bar baz foo>);
    isa-ok $m, MixHash, '&MixHash.new given a Mix produces a MixHash';
    is +$m, 1, "... with one element";
}

# Not sure how one should do this with the new MixHash constructor
# {
#     my $m = MixHash.new(set <foo bar foo bar baz foo>);
#     $m<bar> += 2;
#     my $c = MixHash.new($m);
#     isa-ok $c, MixHash, '&MixHash.new given a MixHash produces a MixHash';
#     is showkv($c), 'bar:3 baz:1 foo:1', '... with the right elements';
#     $c<manning> = 10;
#     is showkv($c), 'bar:3 baz:1 foo:1 manning:10', 'Creating a new element works';
#     is showkv($m), 'bar:3 baz:1 foo:1', '... and does not affect the original MixHash';
# }

{
    my $m = { foo => 10.1, bar => 1.2, baz => 2.3}.MixHash;
    is $m.total, 13.6, 'make sure .total is ok';
    is $m.elems, 3, 'make sure .elems is ok';

    # .list is just the keys, as per TimToady: 
    # http://irclog.perlgeek.de/perl6/2012-02-07#i_5112706
    isa-ok $m.list.elems, 3, ".list returns 3 things";
    is $m.list.grep(Pair).elems, 3, "... all of which are Pairs";

    isa-ok $m.pairs.elems, 3, ".pairs returns 3 things";
    is $m.pairs.grep(Pair).elems, 3, "... all of which are Pairs";
    is $m.pairs.grep({ .key ~~ Str }).elems, 3, "... the keys of which are Strs";
    is $m.pairs.grep({ .value ~~ Real }).elems, 3, "... and the values of which are Ints";
}

{
    my $m = { foo => 10000000000, bar => 17, baz => 42 }.MixHash;
    my $s;
    my $c;
    lives-ok { $s = $m.perl }, ".perl lives";
    isa-ok $s, Str, "... and produces a string";
    ok $s.chars < 1000, "... of reasonable length";
    lives-ok { $c = EVAL $s }, ".perl.EVAL lives";
    isa-ok $c, MixHash, "... and produces a MixHash";
    is showkv($c), showkv($m), "... and it has the correct values";
}

{
    my $m = { foo => 2, bar => 3, baz => 1 }.MixHash;
    my $s;
    lives-ok { $s = $m.Str }, ".Str lives";
    isa-ok $s, Str, "... and produces a string";
    is $s.split(" ").sort.join(" "), "bar(3) baz foo(2)", "... which only contains bar baz and foo with the proper counts and separated by spaces";
}

{
    my $m = { foo => 10000000000, bar => 17, baz => 42 }.MixHash;
    my $s;
    lives-ok { $s = $m.gist }, ".gist lives";
    isa-ok $s, Str, "... and produces a string";
    ok $s.chars < 1000, "... of reasonable length";
    ok $s ~~ /foo/, "... which mentions foo";
    ok $s ~~ /bar/, "... which mentions bar";
    ok $s ~~ /baz/, "... which mentions baz";
}

# L<S02/Names and Variables/'C<%x> may be bound to'>

{
    my %b := MixHash.new("a", "b", "c", "b");
    isa-ok %b, MixHash, 'A MixHash bound to a %var is a MixHash';
    is showkv(%b), 'a:1 b:2 c:1', '...with the right elements';

    is %b<b>, 2, 'Single-key subscript (existing element)';
    is %b<santa>, 0, 'Single-key subscript (nonexistent element)';

    lives-ok { %b<a> = 4 }, "Assign to an element";
    is %b<a>, 4, "... and gets the correct value";
}

# L<S32::Containers/MixHash/roll>

{
    my $m = MixHash.new("a", "b", "b");

    my $a = $m.roll;
    ok $a eq "a" || $a eq "b", "We got one of the two choices";

    isa-ok $m.roll, Str, ".roll with no arguments returns a key of the MixHash";
    ok $m.roll(0) ~~ Iterable, ".roll(0) gives you an Iterable";
    ok $m.roll(1) ~~ Iterable, ".roll(1) gives you an Iterable";
    ok $m.roll(2) ~~ Iterable, ".roll(2) gives you an Iterable";
    is +$m.roll(0), 0, ".roll(0) returns 0 results";
    is +$m.roll(1), 1, ".roll(1) returns 1 result";

    my @a = $m.roll(2);
    is +@a, 2, '.roll(2) returns the right number of items';
    is @a.grep(* eq 'a').elems + @a.grep(* eq 'b').elems, 2, '.roll(2) returned "a"s and "b"s';

    @a = $m.roll: 100;
    is +@a, 100, '.roll(100) returns 100 items';
    ok 2 < @a.grep(* eq 'a') < 75, '.roll(100) (1)';
    ok @a.grep(* eq 'a') + 2 < @a.grep(* eq 'b'), '.roll(100) (2)';

    @a = $m.roll(*)[^100];
    ok 2 < @a.grep(* eq 'a') < 75, '.roll(*)[^100] (1)';
    ok @a.grep(* eq 'a') + 2 < @a.grep(* eq 'b'), '.roll(*)[^100] (2)';

    #?niecza skip '.total NYI'
    is $m.total, 3, '.roll should not change MixHash';
    is $m.elems, 2, '.roll should not change MixHash';
}

{
    my $m = {a => 100000000000, b => 1, c => -100000000000}.MixHash;
    is $m.total, 1, 'make sure total is ok';
    is $m.elems, 3, '.roll should not change MixHash';

    my $a = $m.roll;
    ok $a eq "a" || $a eq "b", "We got one of the two choices (and this was pretty quick, we hope!)";

    my @a = $m.roll: 100;
    is +@a, 100, '.roll(100) returns 100 items';
    ok @a.grep(* eq 'a') > 97, '.roll(100) (1)';
    ok @a.grep(* eq 'b') < 3, '.roll(100) (2)';
    #?niecza skip '.total NYI'
    is $m.total, 1, '.roll should not change MixHash';
    is $m.elems, 3, '.roll should not change MixHash';
}

# L<S32::Containers/MixHash/pick>

{
    my $m = MixHash.new("a", "b", "b");
    throws-like { $m.pick },
      Exception,
      '.pick does not work on MixHash';
}

# L<S32::Containers/MixHash/grab>

#?niecza skip '.grab NYI'
{
    my $m = <a b b c c c>.MixHash;
    throws-like { $m.grab },
      Exception,
      'cannot call .grab on a MixHash';
}


# L<S32::Containers/MixHash/grabpairs>

#?niecza skip '.grabpairs NYI'
{
    my $m = MixHash.new("a", "b", "b");

    my $a = $m.grabpairs[0];
    isa-ok $a, Pair, 'did we get a Pair';
    ok $a.key eq "a" || $a.key eq "b", "We got one of the two choices";

    my @a = $m.grabpairs(2);
    is +@a, 1, '.grabpairs(2) returns the right number of items';
    is @a.grep( {.isa(Pair)} ).Num, 1, 'are they all Pairs';
    ok @a[0].key eq "a" || @a[0].key eq "b", "We got one of the two choices";
    is $m.total, 0, '.grabpairs *should* change MixHash';
    is $m.elems, 0, '.grabpairs *should* change MixHash';
}

#?niecza skip '.grabpairs NYI'
{
    my $m = (a=>1.1,b=>2.2,c=>3.3,d=>4.4,e=>5.5,f=>6.6,g=>7.7,h=>8.8).MixHash;
    my @a = $m.grabpairs: *;
    is +@a, 8, '.grabpairs(*) returns the right number of items';
    is @a.grep( {.isa(Pair)} ).Num, 8, 'are they all Pairs';
    is @a.grep( {1.1 <= .value <= 8.8} ).Num, 8, 'and they all have an expected value';
    is @a.sort.map({.key}).join, "abcdefgh", 'MixHash.grabpairs(*) gets all elements';
    isnt @a.map({.key}).join, "abcdefgh", 'MixHash.grabpairs(*) returns elements in a random order';
    is $m.total, 0, '.grabpairs *should* change MixHash';
    is $m.elems, 0, '.grabpairs *should* change MixHash';
}

#?rakudo skip "'is TypeObject' NYI RT #124490"
#?niecza skip "Trait name not available on variables"
{
    my %h is MixHash = a => 1, b => 0, c => 2;
    nok %h<b>:exists, '"b", initialized to zero, does not exist';
    is +%h.keys, 2, 'Inititalization worked';
    is %h.elems, 3, '.elems works';
    isa-ok %h<nonexisting>, Int, '%h<nonexisting> is an Int';
    is %h<nonexisting>, 0, '%h<nonexisting> is 0';
}

#?rakudo skip "'is TypeObject' NYI RT #124490"
#?niecza skip "Trait name not available on variables"
{
    my %h is MixHash = a => 1, b => 0, c => 2;

    lives-ok { %h<c> = 0 }, 'can set an item to 0';
    nok %h<c>:exists, '"c", set to zero, does not exist';
    is %h.elems, 1, 'one item left';
    is %h.keys, ('a'), '... and the right one is gone';

    lives-ok { %h<c>++ }, 'can add (++) an item that was removed';
    is %h.keys.sort, <a c>, '++ on an item reinstates it';
}

#?rakudo skip "'is TypeObject' NYI RT #124490"
#?niecza skip "Trait name not available on variables"
{
    my %h is MixHash = a => 1, c => 1;

    lives-ok { %h<c>++ }, 'can "add" (++) an existing item';
    is %h<c>, 2, '++ on an existing item increments the counter';
    is %h.keys.sort, <a c>, '++ on an existing item does not add a key';

    lives-ok { %h<a>-- }, 'can remove an item with decrement (--)';
    is %h.keys, ('c'), 'decrement (--) removes items';
    nok %h<a>:exists, 'item is gone according to exists too';
    is %h<a>, 0, 'removed item is zero';

    lives-ok { %h<a>-- }, 'remove a missing item lives';
    is %h.keys, ('c'), 'removing missing item does not change contents';
    is %h<a>, 0, 'item removed again is still zero';
}

#?niecza skip "Trait name not available on variables"
{
    my %h of MixHash;
    ok %h.of.perl eq 'MixHash', 'is the hash really a MixHash';
    #?rakudo 2 todo 'in flux'
    lives-ok { %h = mix <a b c d c b> }, 'Assigning a Mix to a MixHash';
    is %h.keys.sort.map({ $^k ~ ':' ~ %h{$k} }).join(' '),
        'a:1 b:2 c:2 d:1', '... works as expected';
}

{
    isa-ok 42.MixHash, MixHash, "Method .MixHash works on Int-1";
    is showkv(42.MixHash), "42:1", "Method .MixHash works on Int-2";
    isa-ok "blue".MixHash, MixHash, "Method .MixHash works on Str-1";
    is showkv("blue".MixHash), "blue:1", "Method .MixHash works on Str-2";
    my @a = <Now the cross-handed set was the Paradise way>;
    isa-ok @a.MixHash, MixHash, "Method .MixHash works on Array-1";
    is showkv(@a.MixHash), "Now:1 Paradise:1 cross-handed:1 set:1 the:2 was:1 way:1", "Method .MixHash works on Array-2";
    my %x = "a" => 1, "b" => 2;
    isa-ok %x.MixHash, MixHash, "Method .MixHash works on Hash-1";
    is showkv(%x.MixHash), "a:1 b:2", "Method .MixHash works on Hash-2";
    isa-ok (@a, %x).MixHash, MixHash, "Method .MixHash works on List-1";
    is showkv((@a, %x).MixHash), "Now:1 Paradise:1 a:1 b:2 cross-handed:1 set:1 the:2 was:1 way:1",
       "Method .MixHash works on List-2";
}

#?niecza skip '.total/.minpairs/.maxpairs/.fmt NYI'
{
    my $m1 = (a => 1.1, b => 2.2, c => 3.3, d => 4.4).MixHash;
    is $m1.total, 11, '.total gives sum of values (non-empty) 11';
    is +$m1, 11, '+$mix gives sum of values (non-empty) 11';
    is $m1.minpairs, [a=>1.1], '.minpairs works (non-empty) 11';
    is $m1.maxpairs, [d=>4.4], '.maxpairs works (non-empty) 11';
    is $m1.fmt('foo %s').split("\n").sort, ('foo a', 'foo b', 'foo c', 'foo d'),
      '.fmt(%s) works (non-empty 11)';
    is $m1.fmt('%s',',').split(',').sort, <a b c d>,
      '.fmt(%s,sep) works (non-empty 11)';
    is $m1.fmt('%s foo %s').split("\n").sort, ('a foo 1.1', 'b foo 2.2', 'c foo 3.3', 'd foo 4.4'),
      '.fmt(%s%s) works (non-empty 11)';
    is $m1.fmt('%s,%s',':').split(':').sort, <a,1.1 b,2.2 c,3.3 d,4.4>,
      '.fmt(%s%s,sep) works (non-empty 11)';

    my $m2 = (a => 1.1, b => 1.1, c => 3.3, d => 3.3).MixHash;
    is $m2.total, 8.8, '.total gives sum of values (non-empty) 8.8';
    is +$m2, 8.8, '+$mix gives sum of values (non-empty) 8.8';
    is $m2.minpairs.sort, [a=>1.1,b=>1.1], '.minpairs works (non-empty) 8.8';
    is $m2.maxpairs.sort, [c=>3.3,d=>3.3], '.maxpairs works (non-empty) 8.8';

    my $m3 = (a => 1.1, b => 1.1, c => 1.1, d => 1.1).MixHash;
    is $m3.total, 4.4, '.total gives sum of values (non-empty) 4.4';
    is +$m3, 4.4, '+$mix gives sum of values (non-empty) 4.4';
    is $m3.minpairs.sort,[a=>1.1,b=>1.1,c=>1.1,d=>1.1], '.minpairs works (non-empty) 4.4';
    is $m3.maxpairs.sort,[a=>1.1,b=>1.1,c=>1.1,d=>1.1], '.maxpairs works (non-empty) 4.4';

    my $e = ().MixHash;
    is $e.total, 0, '.total gives sum of values (empty)';
    is +$e, 0, '+$mix gives sum of values (empty)';
    is $e.minpairs, (), '.minpairs works (empty)';
    is $e.maxpairs, (), '.maxpairs works (empty)';
    is $e.fmt('foo %s'), "", '.fmt(%s) works (empty)';
    is $e.fmt('%s',','), "", '.fmt(%s,sep) works (empty)';
    is $e.fmt('%s foo %s'), "", '.fmt(%s%s) works (empty)';
    is $e.fmt('%s,%s',':'), "", '.fmt(%s%s,sep) works (empty)';
}

{
    my $m = <a>.MixHash;
    $m<a> = 42.1;
    is $m<a>, 42.1, 'did we set a Real value';
    throws-like { $m<a> = "foo" },
      X::Str::Numeric,
      'Make sure we cannot assign Str on a key';

    $_ = 666.1 for $m.values;
    is $m<a>, 666.1, 'did we set a Real value from a .values alias';
    throws-like { $_ = "foo" for $m.values },
      X::Str::Numeric,
      'Make sure we cannot assign Str on a .values alias';

    .value = 999.1 for $m.pairs;
    is $m<a>, 999.1, 'did we set a Real value from a .pairs alias';
    throws-like { .value = "foo" for $m.pairs },
      X::Str::Numeric,
      'Make sure we cannot assign Str on a .pairs alias';

    for $m.kv -> \k, \v { v = 22.1 };
    is $m<a>, 22.1, 'did we set a Real value from a .kv alias';
    throws-like { for $m.kv -> \k, \v { v = "foo" } },
      X::Str::Numeric,
      'Make sure we cannot assign Str on a .kv alias';
}

{
    my $m = (a=>1.1, b=>2.2, c=>3.3, d=> 4.4).MixHash;
    my @a1;
    for $m.values -> \v { @a1.push(v) }
    is @a1.sort, (1.1,2.2,3.3,4.4), 'did we see all values';
    my @a2;
    for $m.keys -> \v { @a2.push(v) }
    is @a2.sort, <a b c d>, 'did we see all keys';
    my %h1;
    for $m.pairs -> \p { %h1{p.key} = p.value }
    is %h1.sort, (a=>1.1, b=>2.2, c=>3.3, d=>4.4), 'did we see all the pairs';
    my %h2;
    for $m.kv -> \k, \v { %h2{k} = v }
    is %h2.sort, (a=>1.1, b=>2.2, c=>3.3, d=>4.4), 'did we see all the kv';
    my %h3;
    for $m.antipairs -> \p { %h3{p.value} = p.key }
    is %h3.sort, (a=>1.1, b=>2.2, c=>3.3, d=>4.4), 'did we see all the antipairs';
    throws-like { for $m.kxxv -> \k { say k } }, Exception, 'cannot call kxxv';
}

# vim: ft=perl6
