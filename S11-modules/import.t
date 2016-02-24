use v6.c;
use Test;
plan 17;

# L<S11/Importing without loading>

# TODO: add tagged import testing

{
    module A {
        sub Afoo() is export { 'sub A::Afoo' };
        sub Abar()           { 'sub A::Abar' };
        constant pub is export = 42;
        constant priv          = 23;
    }
    import A;

    is Afoo(), 'sub A::Afoo', 'import imports things marked as "is export"';
    dies-ok {EVAL(q{ Abar() })}, "doesn't import non-exported routines";
    # RT #114246
    is pub, 42, 'can import constants';
    dies-ok { EVAL 'priv' }, 'cannot access non-exported constants';
}

#?rakudo skip 'import plus inline module RT #125087'
{
    import (module B {
        sub Bfoo() is export { 'sub B::Bfoo' };
        sub Bbar()           { 'sub B::Bbar' };
    });

    is Bfoo(), 'sub B::Bfoo', 'impporting from inline module';
    dies-ok {EVAL(q{ Bbar() })}, "not importing not-exported routines";
}

{
    module C {
        sub Cfoo() is export { 'sub C::Cfoo' };
        sub Cbar() is export { 'sub C::Cbar' };
    }
    import C;

    is Cfoo(), 'sub C::Cfoo',
       'import imports things implicitly from named module';
    is Cbar(), 'sub C::Cbar',
       'import imports more things implicitly from named module';
}

#?rakudo skip 'import plus inline module RT #125088'
{
    import (module D {
        sub Dfoo() is export { 'sub D::Dfoo' };
        sub Dbar() is export { 'sub D::Dbar' };
    });

    is Dfoo(), 'sub D::Dfoo',
       'import imports things implicitly from inlined module';
    is Dbar(), 'sub D::Dbar',
       'import imports more things implicitly from inlined module';
}

{
    module E {
        sub e1 is export(:A) { 'E::e1' }
        sub e2 is export(:B) { 'E::e2' }
    }
    import E :B;
    dies-ok { EVAL 'e1' }, 'importing by tag is sufficiently selective';
    is e2(), 'E::e2',      'importing by tag';
    {
        import E :ALL;
        is e1() ~ e2(), 'E::e1E::e2', 'import :ALL';
    }
}

# RT #118965 - multiple overlapping imports should not bomb

{
    module F {
        sub f1() is export(:here, :there) { 42 };
    }
    import F :here, :there;
    is f1(), 42, 'can import the same symbol through multiple tags';
}

# RT #118231
{
    lives-ok { EVAL 'use Test' },
        'can import the same thing twice';   ## the first import at line 2 ;)
}

#?niecza skip 'is export not available for variables'
{
    module G {
        our $gee is export = 42;
    }
    import G;
    is $gee, 42, 'can import an our-scoped variable';

    throws-like 'module H { my $eidge is export = 42 }', X::Comp::Trait::Scope,
        type      => 'is',
        subtype   => 'export',
        declaring => 'variable',
        scope     => 'my',
        supported => ['our'];
}

# vim: ft=perl6
