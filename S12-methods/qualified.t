use v6.c;

use Test;

plan 2;

class Parent {
    method me {
        self;
    }
}

class Child is Parent {
    method myself {
        self.Parent::me();
    }
}

role R {
    method me {
        self;
    }
}

class Consumer does R {
    method myself {
        self.R::me();
    }
}

my $child = Child.new;
is( $child.myself, $child, 'Qualified method calls should use the original self' );

my $consumer = Consumer.new;
is( $consumer.myself, $consumer, 'Qualified method calls should use the original self' );

# vim: ft=perl6
