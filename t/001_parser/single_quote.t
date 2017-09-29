use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAUXB2JhcidiYXoCAAAAB3N0cmluZzQXBmJhcmJhegIAAAAHc3RyaW5nMhcZQzpcVXNl
cnNcbm9kZWpzXHRlbXBsYXRlcwIAAAAHc3RyaW5nNRcHZm9vImJhcgIAAAAHc3RyaW5nMxcGZm9v
YmFyAgAAAAdzdHJpbmcx

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/single_quote.toml: strict_mode: $strict_mode";
}

__DATA__
string1='foobar'
string2="barbaz"
string3='foo"bar'
string4="bar'baz"
string5='C:\Users\nodejs\templates'
