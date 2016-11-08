use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAcIqgIAAAAEa2V5MgkAUZ9lAgAAAARrZXk2CG8CAAAABGtleTQJAAAD6AIAAAAEa2V5
NQkAADA5AgAAAARrZXk3CIACAAAABGtleTMI4wIAAAAEa2V5MQ==

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/integer.toml: strict_mode: $strict_mode";
}

__DATA__
key1 = +99
key2 = 42
key3 = 0
key4 = -17
key5 = 1_000
key6 = 5_349_221
key7 = 1_2_3_4_5
