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

    is_deeply $data, {
        empty => {
            map { $_ => '' } qw/double_quote single_quote multi_line/,
        },
        zero => {
            map { $_ => '0' } qw/double_quote single_quote multi_line/,
        },
        one => {
            map { $_ => '1' } qw/double_quote single_quote multi_line/,
        },
        two => {
            map { $_ => '2' } qw/double_quote single_quote multi_line/,
        },
    };
}

__DATA__
[empty]
double_quote=""
single_quote=''
multi_line="""
"""

[zero]
double_quote="0"
single_quote='0'
multi_line="""
0"""

[one]
double_quote="1"
single_quote='1'
multi_line="""
1"""

[two]
double_quote="2"
single_quote='2'
multi_line="""
2"""
