use strict;
use warnings;
use utf8;

use Test::More  tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQkDAAAAAQQDAAAAAgQDAAAABQQCAAAAAgoCXSAKAyAjIAAAAAp0ZXN0X2FycmF5CiAgU2FtZSB0
aGluZywgYnV0IHdpdGggYSBzdHJpbmcgIwAAABNhbm90aGVyX3Rlc3Rfc3RyaW5nCi8gQW5kIHdo
ZW4gIidzIGFyZSBpbiB0aGUgc3RyaW5nLCBhbG9uZyB3aXRoICMgIgAAABJoYXJkZXJfdGVzdF9z
dHJpbmcEAgAAAAIKFVRlc3QgIzExIF1wcm92ZWQgdGhhdAobRXhwZXJpbWVudCAjOSB3YXMgYSBz
dWNjZXNzAAAAC3Rlc3RfYXJyYXkyBAMAAAACCihZb3UgZG9uJ3QgdGhpbmsgc29tZSB1c2VyIHdv
bid0IGRvIHRoYXQ/AAAABXdoYXQ/BAIAAAABCgFdAAAAEG11bHRpX2xpbmVfYXJyYXkAAAAEYml0
IwAAAARoYXJkCh1Zb3UnbGwgaGF0ZSBtZSBhZnRlciB0aGlzIC0gIwAAAAt0ZXN0X3N0cmluZwAA
AAN0aGU=

__EXPECTED__

my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime);
my $data   = $parser->parse($toml);
note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
is_deeply $data => $expected, "t/toml/hard_example.toml";

eval { TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict_mode => 1)->parse($toml) };
like $@, qr{\ASyntax Error: line:16}m;

__DATA__
# Test file for TOML
# Only this one tries to emulate a TOML file written by a user of the kind of parser writers probably hate
# This part you'll really hate

[the]
test_string = "You'll hate me after this - #"          # " Annoying, isn't it?

    [the.hard]
    test_array = [ "] ", " # "]      # ] There you go, parse this!
    test_array2 = [ "Test #11 ]proved that", "Experiment #9 was a success" ]
    # You didn't think it'd as easy as chucking out the last #, did you?
    another_test_string = " Same thing, but with a string #"
    harder_test_string = " And when \"'s are in the string, along with # \""   # "and comments are there too"
    # Things will get harder
    
        [the.hard.bit#]
        what? = "You don't think some user won't do that?"
        multi_line_array = [
            "]",
            # ] Oh yes I did
            ]

# Each of the following keygroups/key value pairs should produce an error. Uncomment to them to test

#[error]   if you didn't catch this, your parser is broken
#string = "Anything other than tabs, spaces and newline after a keygroup or key value pair has ended should produce an error unless it is a comment"   like this
#array = [
#         "This might most likely happen in multiline arrays",
#         Like here,
#         "or here,
#         and here"
#         ]     End of array comment, forgot the #
#number = 3.14  pi <--again forgot the #         


