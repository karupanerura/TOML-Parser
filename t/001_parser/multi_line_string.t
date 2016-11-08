use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAYXHEkgW2R3XW9uJ3QgbmVlZCBcZHsyfSBhcHBsZXMCAAAABnJlZ2V4MhcsVGhlIHF1
aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4CAAAABGtleTIXHlJvc2VzIGFy
ZSByZWQKVmlvbGV0cyBhcmUgYmx1ZQIAAAAEa2V5MBdfVGhlIGZpcnN0IG5ld2xpbmUgaXMKdHJp
bW1lZCBpbiByYXcgc3RyaW5ncy4KICAgQWxsIG90aGVyIHdoaXRlc3BhY2UKICAgICAgaXMgcHJl
c2VydmVkLgogICAgICACAAAABWxpbmVzFyxUaGUgcXVpY2sgYnJvd24gZm94IGp1bXBzIG92ZXIg
dGhlIGxhenkgZG9nLgIAAAAEa2V5MRcsVGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRo
ZSBsYXp5IGRvZy4CAAAABGtleTM=

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/multi_line_string.toml: strict_mode: $strict_mode";
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
