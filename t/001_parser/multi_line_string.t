use strict;
use warnings;
use utf8;

use Test::More  tests => 2;
use Storable qw/thaw/;
use MIME::Base64;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoDAAAABgoeUm9zZXMgYXJlIHJlZApWaW9sZXRzIGFyZSBibHVlAAAABGtleTAKLFRoZSBxdWlj
ayBicm93biBmb3gganVtcHMgb3ZlciB0aGUgbGF6eSBkb2cuAAAABGtleTEKLFRoZSBxdWljayBi
cm93biBmb3gganVtcHMgb3ZlciB0aGUgbGF6eSBkb2cuAAAABGtleTMKX1RoZSBmaXJzdCBuZXds
aW5lIGlzCnRyaW1tZWQgaW4gcmF3IHN0cmluZ3MuCiAgIEFsbCBvdGhlciB3aGl0ZXNwYWNlCiAg
ICAgIGlzIHByZXNlcnZlZC4KICAgICAgAAAABWxpbmVzCixUaGUgcXVpY2sgYnJvd24gZm94IGp1
bXBzIG92ZXIgdGhlIGxhenkgZG9nLgAAAARrZXkyChxJIFtkd11vbid0IG5lZWQgXGR7Mn0gYXBw
bGVzAAAABnJlZ2V4Mg==

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "multi_line_string.toml: strict: $strict";
}

__DATA__
key0 = """
Roses are red
Violets are blue"""

# The following strings are byte-for-byte equivalent:
key1 = "The quick brown fox jumps over the lazy dog."

key2 = """
The quick brown \


  fox jumps over \
    the lazy dog."""

key3 = """\
       The quick brown \
       fox jumps over \
       the lazy dog.\
       """

regex2 = '''I [dw]on't need \d{2} apples'''
lines  = '''
The first newline is
trimmed in raw strings.
   All other whitespace
      is preserved.
      '''
