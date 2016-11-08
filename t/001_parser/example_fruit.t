use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAEEAgAAAAIEGQAAAAADFwVhcHBsZQIAAAAEbmFtZQQZAAAAAAIXA3JlZAIAAAAFY29s
b3IXBXJvdW5kAgAAAAVzaGFwZQIAAAAIcGh5c2ljYWwEAgAAAAIEGQAAAAABFw1yZWQgZGVsaWNp
b3VzAgAAAARuYW1lBBkAAAAAARcMZ3Jhbm55IHNtaXRoAgAAAARuYW1lAgAAAAd2YXJpZXR5BBkA
AAAAAhcGYmFuYW5hAgAAAARuYW1lBAIAAAABBBkAAAAAARcIcGxhbnRhaW4CAAAABG5hbWUCAAAA
B3ZhcmlldHkCAAAABWZydWl0

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/example_fruit.toml: strict_mode: $strict_mode";
}

__DATA__
[[fruit]]
  name = "apple"

  [fruit.physical]
    color = "red"
    shape = "round"

  [[fruit.variety]]
    name = "red delicious"

  [[fruit.variety]]
    name = "granny smith"

[[fruit]]
  name = "banana"

  [[fruit.variety]]
    name = "plantain"
