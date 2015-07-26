use v6;
use Test;

plan 23;

{
    my $p = Promise.new;
    is $p.status, Planned, "Newly created Promise has Planned status";
    nok $p.Bool, "Newly created Promise has now result yet";
    nok ?$p, "Newly created Promise is false";
    dies-ok { $p.cause }, "Cannot call cause on a Planned Promise";
    
    $p.keep("kittens");
    is $p.status, Kept, "Kept Promise has Kept status";
    ok $p.Bool, "Kept Promise has a result";
    ok ?$p, "Kept Promise is true";
    is $p.result, "kittens", "Correct result";
    
    dies-ok { $p.cause }, "Cannot call cause on a Kept Promise";
    throws-like { $p.cause }, X::Promise::CauseOnlyValidOnBroken,
        status => 'Kept';
    dies-ok { $p.keep("eating") }, "Cannot re-keep a Kept Promise";
    throws-like { $p.keep('eating') }, X::Promise::Vowed;
    dies-ok { $p.break("bad") }, "Cannot break a Kept Promise";
}

{
    my $p = Promise.new;
    $p.break("glass");
    is $p.status, Broken, "Broken Promise has Broken status";
    ok $p.Bool, "Broken Promise has a result";
    ok ?$p, "Broken Promise is true";
    isa-ok $p.cause, Exception, "cause returns an exception";
    is $p.cause.message, "glass", "Correct message";
    dies-ok { $p.result }, "result throws exception";
    
    dies-ok { $p.keep("eating") }, "Cannot keep a Broken Promise";
    dies-ok { $p.break("bad") }, "Cannot re-break a Broken Promise";
}

{ # RT #124190
    my $p = Promise.new;
    my $vowname = $p.vow.^name;

    ok Promise.WHO{$vowname} :!exists, "the nested Vow class is lexically scoped";
}

# RT #125257
{
    throws-like 'await', Exception, 'bare "await" dies';
}
