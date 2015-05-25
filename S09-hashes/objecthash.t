use v6;
use Test;

plan 32;

{
    class A { method Str() { 'foo' } };
    my $a = A.new;

    my %h{Any};
    %h{$a} = 'blubb';
    is  %h{$a}, 'blubb', 'Any-typed hash access (+)';
    nok %h{A.new},       'and the hash really uses ===-semantics';
    dies-ok { %h{Mu.new} = 3 }, 'Any-typed hash does not like Mu keys';
    ok %h.keys[0] === $a, 'returned key is correct';
} #4

{
    my %h{Int};
    %h{2} = 3;
    is %h{1 + 1}, 3, 'value-type semantics';
    dies-ok { %h{'foo'} }, 'non-conformant type dies';
} #2

# combinations of typed and objecthash
{
    my Int %h{Rat};
    %h{0.5} = 1;
    %h{0.3} = 2;
    dies-ok { %h{2} = 3 },     'key type mismatch';
    dies-ok { %h{0.5} = 0.2 }, 'value type mismatch';
    dies-ok { %h{2} = 0.5 },   'key and value type mismatch';
    is %h.keys.sort.join(','), '0.3,0.5', '.keys';
    is ~%h.values.sort,        '1 2',     '.values';
    isa-ok %h.kv.flat[0],      Rat,       '.kv types (1)';
    isa-ok %h.kv.flat[1],      Int,       '.kv types (2)';
    isa-ok %h.pairs[0].key,    Rat,       '.pairs.key type';
    isa-ok %h.pairs[0].value,  Int,       '.pairs.value type';
    is %h.elems,               2,         '.elems';
    lives-ok { %h{0.2} := 3 }, 'binding to typed objecthash elements';
    is %h.elems,               3,         'updated .elems';
    dies-ok  { %h{ 3 } := 3 }, 'binding key type check failure';
    dies-ok  { %h{0.2} := 'a' }, 'binding value type check failure';
    dies-ok  { %h.push: 0.5 => 2 },
             'Hash.push fails when the resulting array conflicts with the type check';
    lives-ok { %h.push: 0.9 => 3 }, 'Hash.push without array creation is OK';
    dies-ok  { %h.push: 1 => 3 },   'Hash.push key type check failure';
    dies-ok  { %h.push: 1.1 => 0.2 }, 'Hash.push value type check failure';
} #18

{
    my %h{Any};
    %h = 1, 2;
    ok %h.keys[0] === 1, 'list assignment + object hashes';
} #1

{
    my %h{Mu};
    #?rakudo 2 skip 'oh noes, it dies'
    ok %h{Mu} = 2, "just make the fudging work";
    is %h{Mu}, 2, 'using Mu as a key';
    ok %h{Any} = 3, "just make the fudging work";
    #?rakudo todo 'oh noes, it dies'
    is %h{Any}, 3, 'using Any as a key';
    #?rakudo skip 'oh noes, it dies'
    is %h{ Mu, Any }.join(","), "2,3", 'check slice access on Mu';
    #?rakudo todo 'oh noes, it dies'
    is %h{*}.join(","), "2,3", 'check whatever access with Mu as key';
} #6

# RT #118037
{
    my %h{Any};
    %h{Any}=1;
    ok %h{Any}:exists, '.exists returns True on a %h{Any} in a TypedHash';
}
