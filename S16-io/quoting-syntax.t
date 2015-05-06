use v6;
use Test;

plan 11;
# L<S16::IO/IO/=head2 Special Quoting Syntax>

# basic
#?rakudo skip "two terms in a row / unrecognized adverb RT #124672"
{
	#?niecza 2 skip "Unhandled exception"
	isa-ok qp{/path/to/file}, IO::Path;
	isa-ok q:p{/path/to/file}, IO::Path;
	is qp{/path/to/file}.path, "/path/to/file";
	is q:p{/path/to/file}.path, "/path/to/file";
}

#with interpolation
#?rakudo skip "undeclared routine / urecognized adverb RT #124673"
{
	my $dir = "/tmp";
	my $file = "42";
	#?niecza skip "too late for: qq"
	isa-ok qp:qq{$dir/$file}, IO::Path;
	isa-ok qq:p{$dir/$file}, IO::Path;

	#?niecza skip "too late for: qq"
	is qp:qq{$dir/$file}.path, "/tmp/42";
	is qq:p{$dir/$file}.path, "/tmp/42";
}

# :win constraints
#?rakudo skip "two terms in a row RT #124674"
#?niecza skip "confused"
{
	isa-ok p:win{C:\Program Files\MS Access\file.file}, IO::Path;

	# backlash quoting should be disabled
	ok p:win{c:\no}.path ~~ /no$/;
}

# :unix constraints
#?rakudo skip "Unsupported use of /s RT #124675"
#?niecza skip "Unsupported use of suffix regex modifiers"
{
	isa-ok p:unix{/usr/src/bla/myfile?:%.file}, IO::Path;
}

