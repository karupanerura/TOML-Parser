package TOML::Parser::Tokenizer::Strict;
use 5.008005;
use strict;
use warnings;

use parent qw/TOML::Parser::Tokenizer/;
BEGIN { import TOML::Parser::Tokenizer qw/:constant/ }

sub grammar_regexp {
    my $grammar_regexp = {%{ shift->SUPER::grammar_regexp() }};
    $grammar_regexp->{value} = {%{ $grammar_regexp->{value} }};
    $grammar_regexp->{value}->{string} = qr{"(.*?)(?<!(?<!\\)\\)"};
    return $grammar_regexp;
}

my %ALLOWED_TOKEN_MAP = (
    TOKEN_COMMENT() => 1,
);

our $EXPECT_VALUE_TOKEN;
sub _tokenize_value {
    my $class = shift;
    my @tokens = $class->SUPER::_tokenize_value();
    if (defined $EXPECT_VALUE_TOKEN) {
        my $token = $tokens[0][0];
        if (not exists $ALLOWED_TOKEN_MAP{$token} and $token ne $EXPECT_VALUE_TOKEN) {
            $class->_error("Unexpected token. expected: $EXPECT_VALUE_TOKEN, but got: $token");
        }
    }
    return @tokens;
}

sub _tokenize_array {
    my $class = shift;
    local $EXPECT_VALUE_TOKEN;

    no warnings qw/redefine once/;
    local *_tokenize_value = do {
        use warnings qw/redefine once/;
        my $super = \&_tokenize_value;
        sub {
            my @tokens = $super->(@_);
            $EXPECT_VALUE_TOKEN = $tokens[0][0];

            no warnings qw/redefine once/;
            *_tokenize_value = $super;
            return @tokens;
        };
    };

    return $class->SUPER::_tokenize_array();
}

1;
__END__
