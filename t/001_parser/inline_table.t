use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use Storable 2.38 qw/thaw/;
use MIME::Base64;

use TOML::Parser;

my $toml = do { local $/; <DATA> };

my $expected = thaw(decode_base64(<<'__EXPECTED__'));
BQoZAAAAAAQEAgAAAAMEGQAAAAADCIECAAAAAXgIgwIAAAABegiCAgAAAAF5BBkAAAAAAwiIAgAA
AAF5CIcCAAAAAXgIiQIAAAABegQZAAAAAAMIhAIAAAABeQiIAgAAAAF6CIICAAAAAXgCAAAABnBv
aW50cwQZAAAAAAIXDlByZXN0b24tV2VybmVyAgAAAARsYXN0FwNUb20CAAAABWZpcnN0AgAAAARu
YW1lBBkAAAAAAgiCAgAAAAF5CIECAAAAAXgCAAAABXBvaW50BBkAAAAAAwQZAAAAAAMIgQIAAAAB
eAiDAgAAAAF6CIICAAAAAXkCAAAAAWEEAgAAAAIIiAiJAgAAAAFjBBkAAAAAAwiGAgAAAAF5CIUC
AAAAAXgIhwIAAAABegIAAAABYgIAAAAGbmVzdGVk

__EXPECTED__

for my $strict_mode (0, 1) {
    my $parser = TOML::Parser->new(strict_mode => $strict_mode);
    my $data   = $parser->parse($toml);
    note explain { data => $data, expected => $expected } if $ENV{AUTHOR_TESTING};
    is_deeply $data => $expected, "t/toml/inline_table.toml: strict_mode: $strict_mode";
}

__DATA__
name = { first = "Tom", last = "Preston-Werner" }
point = { x = 1, y = 2 }

points = [ { x = 1, y = 2, z = 3 },
           { x = 7, y = 8, z = 9 },
           { x = 2, y = 4, z = 8 } ]

nested = {
  a = {
    x = 1,
    y = 2,
    z = 3
  },
  b = {
    # comment
    x = 5,
    y = 6,
    z = 7
  },
  c = [
    # comment
    8, 9]
}
