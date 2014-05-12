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

is_deeply $data => +{
    string1 => 'foobar',
    string2 => 'barbaz',
    string3 => 'foo"bar',
    string4 => 'bar\'baz',
}, 'single_quote.toml';

__DATA__
string1='foobar'
string2="barbaz"
string3='foo"bar'
string4="bar'baz"
