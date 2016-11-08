use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Test::Deep;
use Test::Deep::Fuzzy;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAkKEzkyMjQ2MTcuNDQ1OTkxMjI4MzECAAAABGtleTgJAA9CQAIAAAAEa2V5NQoFLTAu
MDECAAAABGtleTMKBjMuMTQxNQIAAAAEa2V5MgoGMWUrMTAwAgAAAARrZXk5Cgk2LjYyNmUtMzQC
AAAABGtleTcIgQIAAAAEa2V5MQoFNWUrMjICAAAABGtleTQKBS0wLjAyAgAAAARrZXk2

__EXPECTED__

for my $key (keys %$expected) {
    $expected->{$key} = is_fuzzy_num($expected->{$key}, 0.000001);
}

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    cmp_deeply $data => $expected, "t/toml/float.toml: strict_mode: $strict_mode";
}

__DATA__
key1 = +1.0
key2 = 3.1415
key3 = -0.01
key4 = 5e+22
key5 = 1e6
key6 = -2E-2
key7 = 6.626e-34
key8 = 9_224_617.445_991_228_313
key9 = 1e1_00
