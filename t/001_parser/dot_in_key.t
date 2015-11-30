use strict;
use warnings;
use utf8;

use Test::More  tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoDAAAAAgoHRm9vLkJhcgAAAAdGb28uQmFyCgZGb29CYXIAAAAGRm9vQmFy

__EXPECTED__

my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime);
my $data   = $parser->parse($toml);
note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
is_deeply $data => $expected, "t/toml/dot_in_key.toml";

eval { TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict_mode => 1)->parse($toml) };
like $@, qr/\ASyntax Error: line:2/m;

__DATA__
FooBar="FooBar"
Foo.Bar="Foo.Bar"
