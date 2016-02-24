use v6.c;

use Test;

plan 12;

dies-ok { Supply.Channel }, 'can not be called as a class method';

for ThreadPoolScheduler.new, CurrentThreadScheduler -> $*SCHEDULER {
    diag "**** scheduling with {$*SCHEDULER.WHAT.perl}";

    {
        my $s = Supplier.new;
        my $c = $s.Supply.Channel;
        isa-ok $c, Channel, 'we got a Channel';
        $s.emit(42);
        is $c.receive, 42, 'got first emitted value';
        $s.emit(43);
        $s.emit(44);
        is $c.receive, 43, 'got second emitted value';
        is $c.receive, 44, 'got third emitted value';
        $s.done;
        ok $c.closed, 'doneing closes the Channel';
    }
}

my $s     = Supplier.new;
my $c     = $s.Supply.Channel;
my $done  = 0;
my $times = 10;

my $promise = start { while $done < $times { $c.receive; $done++ } };
$s.emit($_) for ^$times;
await $promise;
is $done, $times, 'did we receive all?';

# vim: ft=perl6 expandtab sw=4
