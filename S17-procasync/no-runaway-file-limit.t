use v6;
use Test;

plan 1;

# RT #125616
my $prog = $*DISTRO.is-win ?? 'ping' !! 'cat';
for ^1000 {
    my $proc = Proc::Async.new($prog, '/tmp/test-file', :w);
    $proc.stdout.tap(-> $data {});
    my $p = $proc.start;
    $proc.close-stdin;
    await $p;
}

pass 'made it to the end';
