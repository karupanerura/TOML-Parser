package TOML::Parser::Tokenizer::Strict;
use 5.010000;
use strict;
use warnings;

use parent qw/TOML::Parser::Tokenizer/;
BEGIN { import TOML::Parser::Tokenizer qw/:constant/ }

sub grammar_regexp {
    my $grammar_regexp = {%{ shift->SUPER::grammar_regexp() }};
    $grammar_regexp->{table}                 = {%{ $grammar_regexp->{table} }};
    $grammar_regexp->{array_of_table}        = {%{ $grammar_regexp->{array_of_table} }};
    $grammar_regexp->{table}->{key}          = qr{(?:"(.*?)(?<!(?<!\\)\\)"|([A-Za-z0-9_-]+))};
    $grammar_regexp->{array_of_table}->{key} = qr{(?:"(.*?)(?<!(?<!\\)\\)"|([A-Za-z0-9_-]+))};
    $grammar_regexp->{key}                   = qr{(?:"(.*?)(?<!(?<!\\)\\)"|([A-Za-z0-9_-]+))\s*=};
    return $grammar_regexp;
}

1;
__END__
