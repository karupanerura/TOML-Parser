use strict;
use warnings;
use utf8;

use Test::More;
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

is_deeply $data => +{
    array1 => [1],
    array2 => [2, [3, 4]]
}, 't/toml/comma_at_last_of_array.toml';

__DATA__
array1 = [1,]
array2 = [
   2
   # empty!!
   ,
   [
      3,
      4,
   ],
]
