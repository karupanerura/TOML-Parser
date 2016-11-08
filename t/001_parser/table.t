use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAYEGQAAAAABBBkAAAAAAQQDAAAAAAIAAAABbAEAAAACyp4CAAAAAWoEGQAAAAABBBkA
AAAAAQQDAAAAAAIAAAABZgIAAAABZQIAAAABZAQZAAAAAAYXBXZhbHVlAQAAAAbKjsedyp4XBXZh
bHVlAgAAAAkxMjcuMC4wLjEXBXZhbHVlAgAAAAhiYXJlX2tleRcFdmFsdWUCAAAAA2tleRcFdmFs
dWUCAAAAEmNoYXJhY3RlciBlbmNvZGluZxcFdmFsdWUCAAAACGJhcmUta2V5AgAAAAV0YWJsZQQZ
AAAAAAEEGQAAAAABFwNwdWcCAAAABHR5cGUCAAAACXRhdGVyLm1hbgIAAAADZG9nBBkAAAAAAQQZ
AAAAAAEEAwAAAAACAAAAAWkCAAAAAWgCAAAAAWcEGQAAAAABBBkAAAAAAQQDAAAAAAIAAAABYwIA
AAABYgIAAAABYQ==

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/table.toml: strict_mode: $strict_mode";
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
