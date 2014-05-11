use strict;
use warnings;
use utf8;
use Test::More tests => 2;

use TOML::Parser;

my $dat = TOML::Parser->new->parse(<<'...');
all="\b\t\n\f\r\"\/\\"
unichar="\u0022"
...

is($dat->{all}, "\x08\x09\x0A\x0C\x0D\x22\x2F\x5C");
is($dat->{unichar}, q{"});
