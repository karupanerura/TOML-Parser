use strict;
use warnings;
use utf8;

use Test::More tests => 2;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict_mode => $strict);
    my $data = $parser->parse($toml);

    is_deeply $data,
        {
        string_zero => '0',
        string_one  => '1',
        string_two  => '2',
        };
}

__DATA__
string_zero="0"
string_one="1"
string_two="2"
