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
BQoDAAAABwjjAAAABGtleTEIbwAAAARrZXk0CQBRn2UAAAAEa2V5NgkAAAPoAAAABGtleTUIgAAA
AARrZXkzCQAAMDkAAAAEa2V5NwiqAAAABGtleTI=

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict_mode => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "integer.toml: strict: $strict";
}

__DATA__
key1 = +99
key2 = 42
key3 = 0
key4 = -17
key5 = 1_000
key6 = 5_349_221
key7 = 1_2_3_4_5

