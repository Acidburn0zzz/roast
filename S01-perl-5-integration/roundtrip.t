use v6;

use Test;

plan(5);

unless EVAL 'EVAL("1", :lang<perl5>)' {
    skip_rest;
    exit;
}

EVAL(q/
package Id;
sub new {
    my ($class, $ref) = @_;
    bless \$ref, $class;
}
sub identity {
    my $self = shift;
    return $$self;
}
/, :lang<perl5>);

my $japh    = { "Just another $_ hacker" };
my $japh2   = -> $name { "Just another $name hacker" };
my $id      = EVAL('sub { Id->new($_[0]) }', :lang<perl5>);

is($id($japh).identity()('Pugs'), 'Just another Pugs hacker', "Closure roundtrips");
is($id($japh2).identity()('Pugs'), 'Just another Pugs hacker', "Closure roundtrips");

my $keys_p5 = EVAL('sub {keys %{$_[0]}}', :lang<perl5>);
my $tohash_p5 = EVAL('sub { return {map {$_ => 1} @_ } }', :lang<perl5>);
my %hash = (foo => 'bar', hate => 'software');
{
    my $foo = $tohash_p5.(keys %hash);
    cmp_ok($foo, &infix:<cmp>, %hash);
    is_deeply([$foo.keys].sort, [%hash.keys].sort);
}

#?niecza skip 'VAR undeclared'
{
    is_deeply([%hash.keys].sort, [$keys_p5($%hash)].sort);
}

# vim: ft=perl6
