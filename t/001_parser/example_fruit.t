use strict;
use warnings;
use utf8;

use Test::More;
use Storable qw/thaw/;
use MIME::Base64;
plan tests => 1;

use TOML::Parser;
use Types::Serialiser;

my $parser = TOML::Parser->new(
    inflate_datetime => sub {
        my $dt = shift;
        $dt =~ s/Z$/+00:00/;
        return $dt;
    },
);

my $data = $parser->parse_fh(\*DATA);

is_deeply $data => thaw(decode_base64(<<'__EXPECTED__')), 'example_fruit.toml';
BQkDAAAAAQQCAAAAAgQDAAAAAwQCAAAAAgQDAAAAAQoNcmVkIGRlbGljaW91cwAAAARuYW1lBAMA
AAABCgxncmFubnkgc21pdGgAAAAEbmFtZQAAAAd2YXJpZXR5BAMAAAACCgVyb3VuZAAAAAVzaGFw
ZQoDcmVkAAAABWNvbG9yAAAACHBoeXNpY2FsCgVhcHBsZQAAAARuYW1lBAMAAAACBAIAAAABBAMA
AAABCghwbGFudGFpbgAAAARuYW1lAAAAB3ZhcmlldHkKBmJhbmFuYQAAAARuYW1lAAAABWZydWl0

__EXPECTED__

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
