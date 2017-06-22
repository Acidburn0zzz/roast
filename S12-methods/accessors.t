use v6;
use Test;

plan 8;

class A {
    has @.a;
    has $.b;
    method test-list-a {
        my $x = 0;
        $x++ for @.a;
        $x;
    }
    method test-scalar-a {
        my $x = 0;
        $x++ for flat 0, $.a;
        $x - 1;
    }
    method test-list-b {
        my $x = 0;
        $x++ for @.b;
        $x;
    }
    method test-scalar-b {
        my $x = 0;
        $x++ for flat 0, $.b;
        $x - 1;
    }
    method test-hash-a {
        my $x = 0;
        $x++ for %.a;
        $x;
    }

}

my $a = A.new(a => (1, 2, 3, 4), b => [3, 4, 5, 6]);
is $a.test-list-a,   4, '@.a contextualizes as (flat) list (1)';
is $a.test-scalar-a, 1, '$.a contextualizes as item (1)';
is $a.test-list-b,   4, '@.b contextualizes as (flat) list (2)';
is $a.test-scalar-b, 1, '$.b contextualizes as item (2)';
is $a.test-hash-a,   2, '%.a contextualizes as hash';

# RT #78678
{
    class Parent {
        has $.x is rw;
        method parent-x() { $!x };
    }
    class Child is Parent {
        has $.x is rw;
        method child-x() { $!x };
    }
    my $o = Child.new(x => 42);
    $o.Parent::x = 5;
    is $o.parent-x, 5, 'parent attribute is separate from child attribute of the same name (parent)';
    is $o.child-x, 42, 'parent attribute is separate from child attribute of the same name (child)';
    is $o.x, 42, '.accessor returns that of the child';

}
