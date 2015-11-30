use strict;
use warnings;
use utf8;
use Test::More tests => 1;

use TOML::Parser;

my $dat = TOML::Parser->new->parse(<<'...');
all="\b\t\n\f\r\"\/\\"
unichar="\u0022"
unichar8="\U00000022"
...

is_deeply $dat, +{
    all      => "\x08\x09\x0A\x0C\x0D\x22\x2F\x5C",
    unichar  => q{"},
    unichar8 => q{"},
};
