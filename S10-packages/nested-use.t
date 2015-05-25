use v6;

use Test;

plan 9;

use lib 't/spec/packages';

lives-ok {
    require Foo;
}, '... we can require Foo';

lives-ok {
    require Bar;
}, '... we can require Bar (which requires Foo)';

lives-ok {
    require FooBar;
}, '... we can require FooBar (which requires Bar (which requires Foo))';

my $foobar = ::FooBar.new();

{
    my $val;
    lives-ok {
        $val = $foobar.foobar()
    }, '... the FooBar::foobar method resolved';
    is($val, 'foobar', '... the FooBar::foobar method resolved');
}

{
    my $val;
    lives-ok {
        $val = $foobar.bar()
    }, '... the Bar::bar method resolved';
    is($val, 'bar', '... the Bar::bar method resolved');
}

{
    my $val;
    lives-ok {
        $val = $foobar.foo()
    }, '... the Foo::foo method resolved';
    is($val, 'foo', '... the Foo::foo method resolved');
}

# vim: ft=perl6
