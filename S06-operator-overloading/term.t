use v6;
use Test;
plan 9;

{
    package Foo {
        constant \term:<∞> = Inf;
        is ∞, Inf, "Can define \\term:<∞> as a constant";
    }
    dies-ok { EVAL "∞" }, "constant \\term:<∞> really is scoped to package";
    is Foo::term:<∞>, Inf, "Constant available from package";
}

{
    {
        my \term:<∞> = Inf;
        is ∞, Inf, "Can define \\term:<∞> as lexical variable";
    }
    dies-ok { EVAL "∞" }, "my \\term:<∞> really is lexical";
}

{
    my $a = 0;
    sub term:<•> { $a++ };
    is •, 0, "Can define &term:<•> as sub";
    is •, 1, "&term:<•> evaluated each time";
}

{
    my $a = 0;
    my &term:<•> = { $a++ };
    is •, 0, "Can define &term:<•> as lexical variable";
    is •, 1, "&term:<•> evaluated each time";
}

