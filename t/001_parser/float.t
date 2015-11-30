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
BQoDAAAACQoGMy4xNDE1AAAABGtleTIIgQAAAARrZXkxChA5MjI0NjE3LjQ0NTk5MTIzAAAABGtl
eTgKBTVlKzIyAAAABGtleTQKBS0wLjAyAAAABGtleTYKCTYuNjI2ZS0zNAAAAARrZXk3CgUtMC4w
MQAAAARrZXkzCQAPQkAAAAAEa2V5NQoGMWUrMTAwAAAABGtleTk=

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "float.toml: strict: $strict";
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

