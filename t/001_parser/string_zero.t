use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAQEGQAAAAADFwExAgAAAAxkb3VibGVfcXVvdGUXATECAAAADHNpbmdsZV9xdW90ZRcB
MQIAAAAKbXVsdGlfbGluZQIAAAADb25lBBkAAAAAAxcAAgAAAAptdWx0aV9saW5lFwACAAAADHNp
bmdsZV9xdW90ZRcAAgAAAAxkb3VibGVfcXVvdGUCAAAABWVtcHR5BBkAAAAAAxcBMgIAAAAKbXVs
dGlfbGluZRcBMgIAAAAMc2luZ2xlX3F1b3RlFwEyAgAAAAxkb3VibGVfcXVvdGUCAAAAA3R3bwQZ
AAAAAAMXATACAAAADHNpbmdsZV9xdW90ZRcBMAIAAAAMZG91YmxlX3F1b3RlFwEwAgAAAAptdWx0
aV9saW5lAgAAAAR6ZXJv

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/string_zero.toml: strict_mode: $strict_mode";
}

__DATA__
[empty]
double_quote=""
single_quote=''
multi_line="""
"""

[zero]
double_quote="0"
single_quote='0'
multi_line="""
0"""

[one]
double_quote="1"
single_quote='1'
multi_line="""
1"""

[two]
double_quote="2"
single_quote='2'
multi_line="""
2"""
