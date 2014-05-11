package TOML::Parser::Tokenizer;
use 5.008005;
use strict;
use warnings;
use utf8;
use re '/m';

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
    until (/\G\z/gco) {
        if (/\G#(.+)/gco) {
            warn "[TOKEN] COMMENT: $1" if DEBUG;
            push @tokens => [TOKEN_COMMENT, pos, $1];
        }
        elsif (/\G\[\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]\]/gco) {
            warn "[TOKEN] ARRAY_OF_TABLE: $1" if DEBUG;
            push @tokens => [TOKEN_ARRAY_OF_TABLE, pos, $1];
        }
        elsif (/\G\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]/gco) {
            warn "[TOKEN] TABLE: $1" if DEBUG;
            push @tokens => [TOKEN_TABLE, pos, $1];
        }
        elsif (/\G([^.\s\\\]]+)\s*=/gco) {
            warn "[TOKEN] KEY: $1" if DEBUG;
            push @tokens => [TOKEN_KEY, pos, $1];
            push @tokens => $class->_tokenize_value();
        }
        elsif (/\G\s+/gco) {
            # pass throughw
            warn "[PASS] WHITESPACE" if DEBUG;
        }
        else {
            $class->_syntax_error();
        }
    }
    return @tokens;
}

sub _tokenize_value {
    my $class = shift;
    if (/\G\s+/sgco) {
        # pass through
        warn "[PASS] WHITESPACE" if DEBUG;
    }

    if (/\G#(.+)/gco) {
        warn "[TOKEN] COMMENT: $1" if DEBUG;
        return [TOKEN_COMMENT, pos, $1];
    }
    elsif (/\G([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z)/gco) {
        warn "[TOKEN] DATETIME: $1" if DEBUG;
        return [TOKEN_DATETIME, pos, $1];
    }
    elsif (/\G(-?[0-9]*\.[0-9]+)/gco) {
        warn "[TOKEN] FLOAT: $1" if DEBUG;
        return [TOKEN_FLOAT, pos, $1];
    }
    elsif (/\G(-?[0-9]+)/gco) {
        warn "[TOKEN] INTEGER: $1" if DEBUG;
        return [TOKEN_INTEGER, pos, $1];
    }
    elsif (/\G(true|false)\s*/gco) {
        warn "[TOKEN] BOOLEAN: $1" if DEBUG;
        return [TOKEN_BOOLEAN, pos, $1];
    }
    elsif (/\G"(.+?)(?<!\\)"/gco) {
        warn "[TOKEN] STRING: $1" if DEBUG;
        return [TOKEN_STRING, pos, $1];
    }
    elsif (/\G\[/gco) {
        warn "[TOKEN] ARRAY" if DEBUG;
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
    if (/\G\s+/sgco) {
        # pass through
        warn "[PASS] WHITESPACE" if DEBUG;
    }
    return if /\G\]/gco;

    my @tokens = $class->_tokenize_value();
    while (/\G,\s*/sgco || !/\G\]/gco) {
        push @tokens => $class->_tokenize_value();
    }
    continue {
        if (/\G\s+/sgco) {
            # pass through
            warn "[PASS] WHITESPACE" if DEBUG;
        }
    }

    return @tokens;
}

sub _syntax_error {
    my $class = shift;

    my $src   = $_;
    my $line  = 0;
    my $start = pos $src;
    while ($src =~ /$/sgco and pos $src <= pos) {
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
