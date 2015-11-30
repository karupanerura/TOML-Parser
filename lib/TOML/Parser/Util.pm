package TOML::Parser::Util;
use 5.008005;
use strict;
use warnings;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/unescape_str/;

sub unescape_str {
    my $str = shift;

    $str =~ s!\\b !\x08!xmgo;      # backspace       (U+0008)
    $str =~ s!\\t !\x09!xmgo;      # tab             (U+0009)
    $str =~ s!\\n !\x0A!xmgo;      # linefeed        (U+000A)
    $str =~ s!\\f !\x0C!xmgo;      # form feed       (U+000C)
    $str =~ s!\\r !\x0D!xmgo;      # carriage return (U+000D)
    $str =~ s!\\" !\x22!xmgo;      # quote           (U+0022)
    $str =~ s!\\/ !\x2F!xmgo;      # slash           (U+002F)
    $str =~ s!\\\\!\x5C!xmgo;      # backslash       (U+005C)
    $str =~ s{\\u([0-9A-Fa-f]{4})}{# unicode         (U+XXXX)
        chr hex $1
    }xmgeo;
    $str =~ s{\\U([0-9A-Fa-f]{8})}{# unicode         (U+XXXXXXXX)
        chr hex $1
    }xmgeo;

    return $str;
}

1;
__END__
