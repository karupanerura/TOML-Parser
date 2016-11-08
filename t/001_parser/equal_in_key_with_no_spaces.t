use strict;
use Test::More tests => 1;

use TOML::Parser;

my $v = TOML::Parser->new->parse(<<'...');
foo="bar=baz"
...

is $v->{foo}, "bar=baz", "equal in key with no spaces around equal";
