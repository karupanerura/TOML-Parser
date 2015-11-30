use strict;
use warnings;
use utf8;

use Test::More  tests => 2;
use Storable qw/thaw/;
use MIME::Base64;

use TOML::Parser;

sub inflate_datetime {
    my $dt = shift;
    $dt =~ s/Z$/+00:00/;
    return $dt;
}

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoDAAAABgQDAAAAAQQDAAAAAQQDAAAAAAAAAAFpAAAAAWgAAAABZwQZAAAAAAEEAwAAAAEEAwAA
AAAAAAABbAEAAAACyp4AAAABagQZAAAAAAYKBXZhbHVlAAAAAAkxMjcuMC4wLjEKBXZhbHVlAQAA
AAbKjsedyp4KBXZhbHVlAAAAAAhiYXJlLWtleQoFdmFsdWUAAAAACGJhcmVfa2V5CgV2YWx1ZQAA
AAADa2V5CgV2YWx1ZQAAAAASY2hhcmFjdGVyIGVuY29kaW5nAAAABXRhYmxlBAMAAAABBAMAAAAB
CgNwdWcAAAAEdHlwZQAAAAl0YXRlci5tYW4AAAADZG9nBAMAAAABBAMAAAABBAMAAAAAAAAAAWMA
AAABYgAAAAFhBAMAAAABBAMAAAABBAMAAAAAAAAAAWYAAAABZQAAAAFk

__EXPECTED__

for my $strict (0, 1) {
    my $parser = TOML::Parser->new(inflate_datetime => \&inflate_datetime, strict_mode => $strict);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "table.toml: strict: $strict";
}

__DATA__
[table]
key = "value"
bare_key = "value"
bare-key = "value"

"127.0.0.1" = "value"
"character encoding" = "value"
"ʎǝʞ" = "value"

[dog."tater.man"]
type = "pug"

[a.b.c]          # this is best practice
[ d.e.f ]        # same as [d.e.f]
[ g .  h  . i ]  # same as [g.h.i]
[ j . "ʞ" . l ]  # same as [j."ʞ".l]
