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
BQkDAAAABgoMVE9NTCBFeGFtcGxlAAAABXRpdGxlBAMAAAAEChkxOTc5LTA1LTI3VDA3OjMyOjAw
KzAwOjAwAAAAA2RvYgoxR2l0SHViIENvZm91bmRlciAmIENFTwpMaWtlcyB0YXRlciB0b3RzIGFu
ZCBiZWVyLgAAAANiaW8KBkdpdEh1YgAAAAxvcmdhbml6YXRpb24KElRvbSBQcmVzdG9uLVdlcm5l
cgAAAARuYW1lAAAABW93bmVyBAMAAAACBAMAAAACCgZlcWRjMTAAAAACZGMKCDEwLjAuMC4xAAAA
AmlwAAAABWFscGhhBAMAAAADCgZlcWRjMTAAAAACZGMXBuS4reWbvQAAAAdjb3VudHJ5CggxMC4w
LjAuMgAAAAJpcAAAAARiZXRhAAAAB3NlcnZlcnMEAwAAAAIEAgAAAAIKBWFscGhhCgVvbWVnYQAA
AAVob3N0cwQCAAAAAgQCAAAAAgoFZ2FtbWEKBWRlbHRhBAIAAAACCIEIggAAAARkYXRhAAAAB2Ns
aWVudHMEAgAAAAIEAwAAAAIJLAYQeQAAAANza3UKBkhhbW1lcgAAAARuYW1lBAMAAAADCgROYWls
AAAABG5hbWUKBGdyYXkAAAAFY29sb3IJEPkReQAAAANza3UAAAAIcHJvZHVjdHMEAwAAAAQEAgAA
AAMJAAAfQQkAAB9BCQAAH0IAAAAFcG9ydHMKCzE5Mi4xNjguMS4xAAAABnNlcnZlchQREUpTT046
OlBQOjpCb29sZWFuCIEAAAAHZW5hYmxlZAkAABOIAAAADmNvbm5lY3Rpb25fbWF4AAAACGRhdGFi
YXNl

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/example.toml: strict: $strict";
}

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


