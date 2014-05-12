package TOML::Parser::Tokenizer;
use 5.008005;
use strict;
use warnings;
use utf8;

use parent qw/Exporter/;

use constant DEBUG => $ENV{TOML_PARSER_TOKENIZER_DEBUG} ? 1 : 0;

BEGIN {
    my @TOKENS = map uc, qw/
        comment
        table
        array_of_table
        key
        integer
        float
        boolean
        datetime
        string
        array_begin
        array_end
    /;
    my %CONSTANTS = map {
        ("TOKEN_$_" => $_)
    } @TOKENS;

    require constant;
    constant->import(\%CONSTANTS);

    # Exporter
    our @EXPORT_OK   = keys %CONSTANTS;
    our %EXPORT_TAGS = (
        constant => [keys %CONSTANTS],
    );
};

sub tokenize {
    my ($class, $src) = @_;

    local $_ = $src;
    return $class->_tokenize();
}

sub _tokenize {
    my $class = shift;

    my @tokens;
    until (/\G\z/mgco) {
        if (/\G#(.+)/mgco) {
            warn "[TOKEN] COMMENT: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_COMMENT, pos, $1];
        }
        elsif (/\G\[\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]\]/mgco) {
            warn "[TOKEN] ARRAY_OF_TABLE: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_ARRAY_OF_TABLE, pos, $1];
        }
        elsif (/\G\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]/mgco) {
            warn "[TOKEN] TABLE: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_TABLE, pos, $1];
        }
        elsif (/\G([^.\s\\\]]+)\s*=/mgco) {
            warn "[TOKEN] KEY: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_KEY, pos, $1];
            push @tokens => $class->_tokenize_value();
        }
        elsif (/\G\s+/mgco) {
            # pass through
            $class->_skip_whitespace();
        }
        else {
            $class->_syntax_error();
        }
    }
    return @tokens;
}

sub _tokenize_value {
    my $class = shift;
    warn "[CALL] _tokenize_value" if DEBUG;

    if (/\G#(.+)/mgco) {
        warn "[TOKEN] COMMENT: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_COMMENT, pos, $1];
    }
    elsif (/\G([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z)/mgco) {
        warn "[TOKEN] DATETIME: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_DATETIME, pos, $1];
    }
    elsif (/\G(-?[0-9]*\.[0-9]+)/mgco) {
        warn "[TOKEN] FLOAT: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_FLOAT, pos, $1];
    }
    elsif (/\G(-?[0-9]+)/mgco) {
        warn "[TOKEN] INTEGER: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_INTEGER, pos, $1];
    }
    elsif (/\G(true|false)\s*/mgco) {
        warn "[TOKEN] BOOLEAN: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_BOOLEAN, pos, $1];
    }
    elsif (/\G(?:"(.+?)(?<!(?<!\\)\\)"|'(.+?)(?<!(?<!\\)\\)')/mgco) {
        warn "[TOKEN] STRING: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_STRING, pos, $1 || $2];
    }
    elsif (/\G\[/mgco) {
        warn "[TOKEN] ARRAY" if DEBUG;
        $class->_skip_whitespace();
        return (
            [TOKEN_ARRAY_BEGIN, pos],
            $class->_tokenize_array(),
            [TOKEN_ARRAY_END, pos],
        );
    }
    else {
        $class->_syntax_error();
    }
}

sub _tokenize_array {
    my $class = shift;
    warn "[CALL] _tokenize_array" if DEBUG;
    return if /\G\]/mgco;

    my @tokens = $class->_tokenize_value();
    while (/\G,\s*/smgco || !/\G\]/mgco) {
        warn "[CONTEXT] _tokenize_array [loop]" if DEBUG;
        $class->_skip_whitespace();
        push @tokens => $class->_tokenize_value();
        $class->_skip_whitespace();
    }

    return @tokens;
}

sub _skip_whitespace {
    my $class = shift;
    if (/\G\s+/smgco) {
        # pass through
        warn "[PASS] WHITESPACE" if DEBUG;
    }
}

sub _syntax_error {
    my $class = shift;

    my $src   = $_;
    my $line  = 1;
    my $start = pos $src || 0;
    while ($src =~ /$/smgco and pos $src <= pos) {
        $start = pos $src;
        $line++;
    }
    my $end   = pos $src;
    my $len   = pos() - $start - 1;

    my $trace = join "\n",
        "Syntax Error: line:$line",
        substr($src, $start || 0, $end - $start),
        (' ' x $len) . '^';
    die $trace, "\n";
}

1;
__END__
