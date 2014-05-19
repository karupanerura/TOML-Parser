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

is_deeply $data => thaw(decode_base64(<<'__EXPECTED__')), 't/toml/empty_string.toml';
BQkDAAAAAQoAAAAABnN0cmluZw==

__EXPECTED__

__DATA__
string = ""

