use v6;


use Test;

plan 4;

# L<S13/Multiple dispatch/"All you have to do to overload them is to define your own multi">

my $here;

#?rakudo skip 'defining operators'
{
    my @a;
    $here = 0;
    multi infix:<..> ( Int $a, Int $b ) { $here++ }
    @a = 1..2;
    is $here, 1, "range operator was redefined";
}

#?rakudo skip 'defining builtins'
{
    my @a;
    $here = 0;
    multi push (@a, *@data ) { $here++ }
    push @a, 2;
    is $here, 1, "push operator was redefined";
}

#?rakudo skip 'parsefail with the :<[]>'
{
    my @a;
    $here = 0;
    multi postcircumfix:<[]> ( *@a ) { $here++ }
    my $x = @a[1];
    #?pugs todo 'bug'
    is $here, 1, "slice fetch was redefined";
}

#?rakudo skip 'parsefail with the :<[]>'
{
    my @a;
    $here = 0;
    multi postcircumfix:<[]> ( *@a ) { $here++ }
    @a[1] = 0;
    #?pugs todo 'bug'
    is $here, 1, "slice store was redefined";
}
