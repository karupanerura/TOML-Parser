use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAIEAgAAAAIEAgAAAAEIggQCAAAAAgiDCIQCAAAABmFycmF5MgQCAAAAAQiBAgAAAAZh
cnJheTE=

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/comma_at_last_of_array.toml: strict_mode: $strict_mode";
}

__DATA__
array1 = [1,]
array2 = [
   [
     2
   ],
   [
      3,
      4,
   ]
   # empty!!
   ,
]
