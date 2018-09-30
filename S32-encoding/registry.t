use Test;
use lib $?FILE.IO.parent(2).add: 'packages';
use Test;
use Test::Util;

plan 15;

for <utf8  utf-8  UTF-8  ascii  iso-8859-1  latin-1> -> $name {
    group-of 3 => "Can find built-in $name encoding" => {
        given Encoding::Registry.find: $name {
            isa-ok  $_, Encoding::Builtin, 'type of result';
            does-ok $_, Encoding, 'does Encoding role';
            is (.alternative-names, .name).flat».fc.any, $name.fc,
                'found right encoding';
        }
    }
}

throws-like { Encoding::Registry.find('utf-29') },
    X::Encoding::Unknown, name => 'utf-29',
    'Unknown encoding throws correct type of exception';

{
    my class TestEncoding does Encoding {
        method name() { 'utf-29' }
        method alternative-names() { ('utf29', 'prime-enc') }
        method encoder() { die "NYI" }
        method decoder() { die "NYI" }
    }

    is-deeply Encoding::Registry.register(TestEncoding), Nil,
        'Can register an encoding';

    isa-ok Encoding::Registry.find('utf-29'), TestEncoding,
        'Can find an encoding by its name';
    isa-ok Encoding::Registry.find('UtF-29'), TestEncoding,
        'Encoding finding by name is case-insensitive';
    isa-ok Encoding::Registry.find('utf29'), TestEncoding,
        'Can find an encoding by its alternative names';
    isa-ok Encoding::Registry.find('Prime-Enc'), TestEncoding,
        'Encoding finding by alternative names is case-insensitive';

    my class TestEncoding2 does Encoding {
        method name() { 'utf-29' }
        method alternative-names() { () }
        method encoder() { die "NYI" }
        method decoder() { die "NYI" }
    }
    throws-like { Encoding::Registry.register(TestEncoding2) },
        X::Encoding::AlreadyRegistered, name => 'utf-29',
        'Cannot register an encoding with an overlapping name';

    my class TestEncoding3 does Encoding {
        method name() { 'utf-17' }
        method alternative-names() { ('prime-enc',) }
        method encoder() { die "NYI" }
        method decoder() { die "NYI" }
    }
    throws-like { Encoding::Registry.register(TestEncoding3) },
        X::Encoding::AlreadyRegistered, name => 'prime-enc',
        'Cannot register an encoding with an overlapping alternative name';
}

{
    my class NoAlternativeNamesEncoding does Encoding {
        method name() { "this-encoding-not-taken" }
        method encoder() { die "NYI" }
        method decoder() { die "NYI" }
    }
    is-deeply Encoding::Registry.register(NoAlternativeNamesEncoding), Nil,
        "Encodings with no alternative names method can be registered";
}
