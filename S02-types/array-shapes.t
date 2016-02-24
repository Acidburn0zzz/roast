use v6.c;
use Test;
plan 24;

# L<S09/Fixed-size arrays>

#?rakudo skip 'array shapes NYI RT #124502'
{
    my @arr[*];
    @arr[42] = "foo";
    is(+@arr, 43, 'my @arr[*] autoextends like my @arr');
}

{
    my @arr[7] = <a b c d e f g>;
    is(@arr, [<a b c d e f g>], 'my @arr[num] can hold num things');
    throws-like q[push @arr, 'h'],
      X::IllegalOnFixedDimensionArray,
      operation => 'push',
      'adding past num items in my @arr[num] dies';
    throws-like '@arr[7]',
      Exception,
      'accessing past num items in my @arr[num] dies';
}

{
    lives-ok { my @arr\    [7] },
      'array with fixed size with unspace';
   #?rakudo 2 todo 'code does not die, array shapes RT #124502'
    throws-like 'my @arr.[8]',
      Exception,  # XXX fix when this block is no longer skipped
      'array with dot form dies';
    throws-like 'my @arr\    .[8]',
      Exception,  # XXX fix when this block is no longer skipped
      'array with dot form and unspace dies';
}

# L<S09/Typed arrays>
{
    my @arr of Int = 1, 2, 3, 4, 5;
    is(@arr, <1 2 3 4 5>, 'my @arr of Type works');
    throws-like q[push @arr, 's'],
      X::TypeCheck,
      'type constraints on my @arr of Type works (1)';
    throws-like 'push @arr, 4.2',
      X::TypeCheck,
      'type constraints on my @arr of Type works (2)';
}
{
    my Int @arr = 1, 2, 3, 4, 5;
    is(@arr, <1 2 3 4 5>, 'my Type @arr works');
    throws-like q[push @arr, 's'],
      X::TypeCheck,
      'type constraints on my Type @arr works (1)';
    throws-like 'push @arr, 4.2',
      X::TypeCheck,
      'type constraints on my Type @arr works (2)';
}

{
    my @arr[5] of Int = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my @arr[Int] of Type works');

    throws-like 'push @arr, 123',
      Exception,
      'boundary constraints on my @arr[Int] of Type works';
}

{
    my int @arr = 1, 2, 3, 4, 5;
    is(@arr, <1 2 3 4 5>, 'my type @arr works');
    is push(@arr, 6), [1,2,3,4,5,6], 'push on native @arr works';
    # RT #125123'
    throws-like 'push @arr, "s"',
      X::TypeCheck,
      'type constraints on my type @arr works (1)';
    throws-like 'push @arr, 4.2',
      X::TypeCheck,
      'type constraints on my type @arr works (2)';
}

{
    my int @arr[5] = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my Type @arr[num] works');

    throws-like 'push @arr, 123',
      X::IllegalOnFixedDimensionArray,
      operation => 'push';
    throws-like 'pop @arr',
      X::IllegalOnFixedDimensionArray,
      operation => 'pop';
    throws-like q[push @arr, 's'],
      X::IllegalOnFixedDimensionArray,
      operation => 'push';
    throws-like 'push @arr, 4.2',
      X::IllegalOnFixedDimensionArray,
      operation => 'push';
}
