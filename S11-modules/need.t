use v6;

use lib '.';

use Test;
plan 2;

{
    need t::spec::packages::Export_PackA;

    is t::spec::packages::Export_PackA::exported_foo(),
       42, 'Can "need" a module';
    throws-like 'exported_foo()',
        X::Undeclared::Symbols, '"need" did not import the default export list';
}

# vim: ft=perl6
