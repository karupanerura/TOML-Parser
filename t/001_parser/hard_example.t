use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAEEGQAAAAACFx1Zb3UnbGwgaGF0ZSBtZSBhZnRlciB0aGlzIC0gIwIAAAALdGVzdF9z
dHJpbmcEGQAAAAAFFyAgU2FtZSB0aGluZywgYnV0IHdpdGggYSBzdHJpbmcgIwIAAAATYW5vdGhl
cl90ZXN0X3N0cmluZwQCAAAAAhcCXSAXAyAjIAIAAAAKdGVzdF9hcnJheQQCAAAAAhcVVGVzdCAj
MTEgXXByb3ZlZCB0aGF0FxtFeHBlcmltZW50ICM5IHdhcyBhIHN1Y2Nlc3MCAAAAC3Rlc3RfYXJy
YXkyFy8gQW5kIHdoZW4gIidzIGFyZSBpbiB0aGUgc3RyaW5nLCBhbG9uZyB3aXRoICMgIgIAAAAS
aGFyZGVyX3Rlc3Rfc3RyaW5nBBkAAAAAAhcoWW91IGRvbid0IHRoaW5rIHNvbWUgdXNlciB3b24n
dCBkbyB0aGF0PwIAAAAFd2hhdD8EAgAAAAEXAV0CAAAAEG11bHRpX2xpbmVfYXJyYXkCAAAABGJp
dCMCAAAABGhhcmQCAAAAA3RoZQ==

__EXPECTED__

my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime);
my $data   = $parser->parse($toml);
note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
is_deeply $data => $expected, 't/toml/hard_example.toml: strict_mode: 0';

eval { TOML::Parser->new(strict_mode => 1)->parse($toml) };
like $@, qr{\ASyntax Error: line:16}m, 't/toml/hard_example.toml: strict_mode: 1';

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
