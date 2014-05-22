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
BQkDAAAAAQQCAAAAAgQDAAAAAwQCAAAAAgQDAAAAAQoNcmVkIGRlbGljaW91cwAAAARuYW1lBAMA
AAABCgxncmFubnkgc21pdGgAAAAEbmFtZQAAAAd2YXJpZXR5CgVhcHBsZQAAAARuYW1lBAMAAAAC
CgVyb3VuZAAAAAVzaGFwZQoDcmVkAAAABWNvbG9yAAAACHBoeXNpY2FsBAMAAAACBAIAAAABBAMA
AAABCghwbGFudGFpbgAAAARuYW1lAAAAB3ZhcmlldHkKBmJhbmFuYQAAAARuYW1lAAAABWZydWl0

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/example_fruit.toml: strict: $strict";
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
