use v6;
use lib 't/spec/packages';

use Test;
use Test::Tap;

plan 75;

dies-ok { Supply.categorize( {...}  ) }, 'can not be called as a class method';
dies-ok { Supply.categorize( {a=>1} ) }, 'can not be called as a class method';
dies-ok { Supply.categorize( [<a>]  ) }, 'can not be called as a class method';

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.perl}";

    {
        my &mapper = { $_ div 10 };
        my %mapper is default(0) = ( 11=>1, 12=>1, 13=>1 );
        my @mapper = (0 xx 10, 1 xx 10);
        for &mapper, $%mapper, $@mapper -> \mapper {
            my $what = mapper.WHAT.perl;
            my $s = Supply.new;
            ok $s ~~ Supply, "we got a base Supply ($what)";
            my $c = $s.categorize( mapper );
            ok $s ~~ Supply, "we got a classification Supply ($what)";

            my @keys;
            my @supplies;
            isa-ok $c.tap( -> $p {
                @keys.push: $p.key;
                @supplies.push: $p.value;
            } ), Tap, "we got a tap ($what)";

            $s.emit($_) for 1,2,3,11,12,13;
            is-deeply @keys, [0,1], "did we get the right keys ($what)";
            tap-ok @supplies[0], [1,2,3],   "got the 0 supply ($what)", :live;
            tap-ok @supplies[1], [11,12,13], "got the 1 supply ($what)", :live;
        }
    }

    {
        my &mapper = { $_ div 10 ?? (0,1) !! () };
        my %mapper is default( () ) = ( 11=>(0,1), 12=>(0,1), 13=>(0,1) );
        my @mapper = ( ().item xx 10, $(0,1) xx 10);
        for &mapper, $%mapper, $@mapper -> \mapper {
            my $what = mapper.WHAT.perl;
            my $s = Supply.new;
            ok $s ~~ Supply, "we got a base Supply ($what)";
            my $c = $s.categorize( mapper );
            ok $s ~~ Supply, "we got a classification Supply ($what)";

            my @keys;
            my @supplies;
            isa-ok $c.tap( -> $p {
                @keys.push: $p.key;
                @supplies.push: $p.value;
            } ), Tap, "we got a tap ($what)";

            $s.emit($_) for 1,2,3,11,12,13;
            is-deeply @keys, [0,1], "did we get the right keys ($what)";
            tap-ok @supplies[0], [11,12,13], "got the 0 supply ($what)", :live;

            my $done = False;
            @supplies[1].tap(done => sub { $done = True });
            $s.done;
            ok $done, 'Sub-supply got .done (RT 123674)';
        }
    }
}
