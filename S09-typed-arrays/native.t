﻿use Test;

plan 3;

# Basic native array tests.
{
    dies-ok { array.new }, 'Must use native array with type parameter (1)';
    dies-ok { array.new(1) }, 'Must use native array with type parameter (2)';
    dies-ok { array.new(1, 2) }, 'Must use native array with type parameter (3)';
}
