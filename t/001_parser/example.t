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

is_deeply $data => thaw(decode_base64(<<'__EXPECTED__')), 'example.toml';
BQkDAAAABgQDAAAAAgQDAAAAAwoIMTAuMC4wLjIAAAACaXAKBmVxZGMxMAAAAAJkYxcG5Lit5Zu9
AAAAB2NvdW50cnkAAAAEYmV0YQQDAAAAAgoGZXFkYzEwAAAAAmRjCggxMC4wLjAuMQAAAAJpcAAA
AAVhbHBoYQAAAAdzZXJ2ZXJzBAMAAAAEChkxOTc5LTA1LTI3VDA3OjMyOjAwKzAwOjAwAAAAA2Rv
YgoSVG9tIFByZXN0b24tV2VybmVyAAAABG5hbWUKMUdpdEh1YiBDb2ZvdW5kZXIgJiBDRU8KTGlr
ZXMgdGF0ZXIgdG90cyBhbmQgYmVlci4AAAADYmlvCgZHaXRIdWIAAAAMb3JnYW5pemF0aW9uAAAA
BW93bmVyBAMAAAACBAIAAAACCgVhbHBoYQoFb21lZ2EAAAAFaG9zdHMEAgAAAAIEAgAAAAIKBWdh
bW1hCgVkZWx0YQQCAAAAAgiBCIIAAAAEZGF0YQAAAAdjbGllbnRzBAMAAAAEBAIAAAADCQAAH0EJ
AAAfQQkAAB9CAAAABXBvcnRzFBERSlNPTjo6UFA6OkJvb2xlYW4IgQAAAAdlbmFibGVkCgsxOTIu
MTY4LjEuMQAAAAZzZXJ2ZXIJAAATiAAAAA5jb25uZWN0aW9uX21heAAAAAhkYXRhYmFzZQQCAAAA
AgQDAAAAAgoGSGFtbWVyAAAABG5hbWUJLAYQeQAAAANza3UEAwAAAAMKBE5haWwAAAAEbmFtZQoE
Z3JheQAAAAVjb2xvcgkQ+RF5AAAAA3NrdQAAAAhwcm9kdWN0cwoMVE9NTCBFeGFtcGxlAAAABXRp
dGxl

__EXPECTED__

__DATA__
# This is a TOML document. Boom.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z # First class dates? Why not?

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # You can indent as you please. Tabs or spaces. TOML don't care.
  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"
  country = "中国" # This should be parsed as UTF-8

[clients]
data = [ ["gamma", "delta"], [1, 2] ] # just an update to make sure parsers support it

# Line breaks are OK when inside arrays
hosts = [
  "alpha",
  "omega"
]

# Products

  [[products]]
  name = "Hammer"
  sku = 738594937

  [[products]]
  name = "Nail"
  sku = 284758393
  color = "gray"

