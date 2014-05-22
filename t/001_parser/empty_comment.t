use strict;
use warnings;
use utf8;

use Test::More  tests => 2;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

my $expected = +{
    aaaa => 1,
    bbbb => 2.5,
    cccc => Types::Serialiser::true(),
    dddd => 'dddd',
};

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/empty_comment.toml: strict: $strict";
}

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
