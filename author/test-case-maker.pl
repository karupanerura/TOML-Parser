use strict;
use warnings;
use utf8;

use JSON 2;
use Storable qw/nfreeze/;
use MIME::Base64;
use File::Slurp qw/slurp/;
use Data::Dumper ();
local $Data::Dumper::Terse    = 1;
local $Data::Dumper::Indent   = 0;
local $Data::Dumper::Sortkeys = 1;

my $file = shift @ARGV or die "Usage: $0 target.toml";

my $toml      = slurp($file);
my $toml_data = decode_json(`ruby -rtoml -rjson -e 'print JSON.dump TOML.load_file("$file")'`);
printf <<'...', $file, encode_base64(nfreeze($toml_data)), $toml;
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

is_deeply $data => thaw(decode_base64(<<'__EXPECTED__')), '%s';
%s
__EXPECTED__

__DATA__
%s
...
