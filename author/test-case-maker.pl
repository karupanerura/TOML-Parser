#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Storable 2.38 qw/nfreeze/;
use MIME::Base64;
use Path::Tiny;
use Data::Dumper ();
use TOML::Parser;
local $Data::Dumper::Terse    = 1;
local $Data::Dumper::Indent   = 0;
local $Data::Dumper::Sortkeys = 1;

my $file = shift @ARGV or die "Usage: $0 target.toml";

my $toml      = path($file)->slurp_utf8;
my $toml_data = TOML::Parser->new->parse($toml);
printf <<'...', encode_base64(nfreeze($toml_data)), $file, $toml =~ s/\n\z//mr;
use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Test::Deep;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
%s
__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    cmp_deeply $data => $expected, "%s: strict_mode: $strict_mode";
}

__DATA__
%s
...
