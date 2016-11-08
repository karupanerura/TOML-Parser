use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAIXBkZvb0JhcgIAAAAGRm9vQmFyFwdGb28uQmFyAgAAAAdGb28uQmFy

__EXPECTED__

my $parser = TOML::Parser->new();
my $data   = $parser->parse($toml);
note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
is_deeply $data => $expected, 't/toml/dot_in_key.toml: strict_mode: 0';

eval { TOML::Parser->new(strict_mode => 1)->parse($toml) };
like $@, qr/\ASyntax Error: line:2/m, 't/toml/dot_in_key.toml: strict_mode: 1';

__DATA__
FooBar="FooBar"
Foo.Bar="Foo.Bar"
