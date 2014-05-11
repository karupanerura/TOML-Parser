use strict;
use warnings;
use utf8;

use Test::More;
use Storable qw/thaw/;
use MIME::Base64;
plan tests => 1;

use TOML::Parser;
use Types::Serialiser;

my $parser = TOML::Parser->new(
    inflate_datetime => sub {
        my $dt = shift;
        $dt =~ s/Z$/+00:00/;
        return $dt;
    },
);

my $data = $parser->parse_fh(\*DATA);

is_deeply $data => thaw(decode_base64(<<'__EXPECTED__')), 'hard_example.toml';
BQkDAAAAAQQDAAAAAgodWW91J2xsIGhhdGUgbWUgYWZ0ZXIgdGhpcyAtICMAAAALdGVzdF9zdHJp
bmcEAwAAAAUEAgAAAAIKAl0gCgMgIyAAAAAKdGVzdF9hcnJheQovIEFuZCB3aGVuICIncyBhcmUg
aW4gdGhlIHN0cmluZywgYWxvbmcgd2l0aCAjICIAAAASaGFyZGVyX3Rlc3Rfc3RyaW5nBAMAAAAC
CihZb3UgZG9uJ3QgdGhpbmsgc29tZSB1c2VyIHdvbid0IGRvIHRoYXQ/AAAABXdoYXQ/BAIAAAAB
CgFdAAAAEG11bHRpX2xpbmVfYXJyYXkAAAAEYml0IwogIFNhbWUgdGhpbmcsIGJ1dCB3aXRoIGEg
c3RyaW5nICMAAAATYW5vdGhlcl90ZXN0X3N0cmluZwQCAAAAAgoVVGVzdCAjMTEgXXByb3ZlZCB0
aGF0ChtFeHBlcmltZW50ICM5IHdhcyBhIHN1Y2Nlc3MAAAALdGVzdF9hcnJheTIAAAAEaGFyZAAA
AAN0aGU=

__EXPECTED__

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

