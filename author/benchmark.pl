use strict;
use warnings;
use utf8;

use Benchmark qw/cmpthese timethese/;

use TOML;
use TOML::Parser;

my $parser = TOML::Parser->new();

my $toml = do { local $/; <DATA> };
cmpthese timethese 10000 => +{
    'TOML' => sub {
        TOML::from_toml($toml);
    },
    'TOML::Parser' => sub {
        $parser->parse($toml);
    },
};

# Benchmark: timing 10000 iterations of TOML, TOML::Parser...
#       TOML: 11 wallclock secs (11.11 usr +  0.02 sys = 11.13 CPU) @ 898.47/s (n=10000)
# TOML::Parser:  7 wallclock secs ( 6.84 usr +  0.01 sys =  6.85 CPU) @ 1459.85/s (n=10000)
#                Rate         TOML TOML::Parser
# TOML          898/s           --         -38%
# TOML::Parser 1460/s          62%           --

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

