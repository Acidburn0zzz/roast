use v6.d;

use Test;

plan 1;

sub foo { die };
foo;

CATCH {
    when * {
        pass 'Top-level handler caught exception'
    }
}
