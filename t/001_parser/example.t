use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAYEAgAAAAIEGQAAAAACCSwGEHkCAAAAA3NrdRcGSGFtbWVyAgAAAARuYW1lBBkAAAAA
AxcEZ3JheQIAAAAFY29sb3IXBE5haWwCAAAABG5hbWUJEPkReQIAAAADc2t1AgAAAAhwcm9kdWN0
cwQZAAAAAAIEAgAAAAIXBWFscGhhFwVvbWVnYQIAAAAFaG9zdHMEAgAAAAIEAgAAAAIXBWdhbW1h
FwVkZWx0YQQCAAAAAgiBCIICAAAABGRhdGECAAAAB2NsaWVudHMXDFRPTUwgRXhhbXBsZQIAAAAF
dGl0bGUEGQAAAAAEBAIAAAADCQAAH0EJAAAfQQkAAB9CAgAAAAVwb3J0cxQREUpTT046OlBQOjpC
b29sZWFuCIECAAAAB2VuYWJsZWQXCzE5Mi4xNjguMS4xAgAAAAZzZXJ2ZXIJAAATiAIAAAAOY29u
bmVjdGlvbl9tYXgCAAAACGRhdGFiYXNlBBkAAAAAAgQZAAAAAAMXBmVxZGMxMAIAAAACZGMXCDEw
LjAuMC4yAgAAAAJpcBcG5Lit5Zu9AgAAAAdjb3VudHJ5AgAAAARiZXRhBBkAAAAAAhcGZXFkYzEw
AgAAAAJkYxcIMTAuMC4wLjECAAAAAmlwAgAAAAVhbHBoYQIAAAAHc2VydmVycwQZAAAAAAQXBkdp
dEh1YgIAAAAMb3JnYW5pemF0aW9uFxQxOTc5LTA1LTI3VDA3OjMyOjAwWgIAAAADZG9iFxJUb20g
UHJlc3Rvbi1XZXJuZXICAAAABG5hbWUXMUdpdEh1YiBDb2ZvdW5kZXIgJiBDRU8KTGlrZXMgdGF0
ZXIgdG90cyBhbmQgYmVlci4CAAAAA2JpbwIAAAAFb3duZXI=

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/example.toml: strict_mode: $strict_mode";
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
