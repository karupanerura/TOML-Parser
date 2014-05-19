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
    aaaa => 1,
    bbbb => 2.5,
    cccc => Types::Serialiser::true(),
    dddd => 'dddd',
}, 't/toml/empty_comment.toml';

__DATA__
#
#
# fooo

#

aaaa =   1 #
bbbb  =  2.5#
cccc   = true# cccc

#

#

#aaaa

dddd="dddd"
