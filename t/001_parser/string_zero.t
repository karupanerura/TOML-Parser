use strict;
use warnings;
use utf8;

use Test::More tests => 1;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $data = TOML::Parser->new->parse($toml);

is_deeply $data, {
    string_zero => '0',
    string_one  => '1',
    string_two  => '2',
};

__DATA__
string_zero = "0"
string_one  = "1"
string_two  = "2"
