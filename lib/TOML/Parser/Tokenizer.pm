package TOML::Parser::Tokenizer;
use 5.008005;
use strict;
use warnings;

use Exporter 5.57 'import';

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

sub grammar_regexp {
    return +{
        comment        => qr{#(.*)},
        table          => qr{\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]},
        array_of_table => qr{\[\[([^.\s\\\]]+(?:\.[^.\s\\\]]+)*)\]\]},
        key            => qr{([^\s]+)\s*=},
        value          => {
            datetime => qr{([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z)},
            float    => qr{(-?[0-9]*\.[0-9]+)},
            integer  => qr{(-?[0-9]+)},
            boolean  => qr{(true|false)},
            string   => qr{(?:"(.*?)(?<!(?<!\\)\\)"|\'(.*?)(?<!(?<!\\)\\)\')},
            array    => {
                start => qr{\[},
                sep   => qr{\s*,\s*},
                end   => qr{\]},
            },
        },
    };
}

sub tokenize {
    my ($class, $src) = @_;

    local $_ = $src;
    return $class->_tokenize();
}

sub _tokenize {
    my $class = shift;
    my $grammar_regexp = $class->grammar_regexp();

    my @tokens;
    until (/\G\z/mgco) {
        if (/\G$grammar_regexp->{comment}/mgc) {
            warn "[TOKEN] COMMENT: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_COMMENT, $1 || ''];
        }
        elsif (/\G$grammar_regexp->{array_of_table}/mgc) {
            warn "[TOKEN] ARRAY_OF_TABLE: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_ARRAY_OF_TABLE, $1];
        }
        elsif (/\G$grammar_regexp->{table}/mgc) {
            warn "[TOKEN] TABLE: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_TABLE, $1];
        }
        elsif (/\G$grammar_regexp->{key}/mgc) {
            warn "[TOKEN] KEY: $1" if DEBUG;
            $class->_skip_whitespace();
            push @tokens => [TOKEN_KEY, $1];
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
    my $grammar_regexp = $class->grammar_regexp();
    warn "[CALL] _tokenize_value" if DEBUG;

    if (/\G$grammar_regexp->{comment}/mgc) {
        warn "[TOKEN] COMMENT: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_COMMENT, $1 || ''];
    }
    elsif (/\G$grammar_regexp->{value}->{datetime}/mgc) {
        warn "[TOKEN] DATETIME: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_DATETIME, $1];
    }
    elsif (/\G$grammar_regexp->{value}->{float}/mgc) {
        warn "[TOKEN] FLOAT: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_FLOAT, $1];
    }
    elsif (/\G$grammar_regexp->{value}->{integer}/mgc) {
        warn "[TOKEN] INTEGER: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_INTEGER, $1];
    }
    elsif (/\G$grammar_regexp->{value}->{boolean}/mgc) {
        warn "[TOKEN] BOOLEAN: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_BOOLEAN, $1];
    }
    elsif (/\G$grammar_regexp->{value}->{string}/mgc) {
        warn "[TOKEN] STRING: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_STRING, $1 || $2 || ''];
    }
    elsif (/\G$grammar_regexp->{value}->{array}->{start}/mgc) {
        warn "[TOKEN] ARRAY" if DEBUG;
        $class->_skip_whitespace();
        return (
            [TOKEN_ARRAY_BEGIN],
            $class->_tokenize_array(),
            [TOKEN_ARRAY_END],
        );
    }
    else {
        $class->_syntax_error();
    }
}

sub _tokenize_array {
    my $class = shift;
    my $grammar_regexp = $class->grammar_regexp()->{value}->{array};
    warn "[CALL] _tokenize_array" if DEBUG;
    return if /\G(?:$grammar_regexp->{sep})?$grammar_regexp->{end}/smgc;

    my @tokens = $class->_tokenize_value();
    while (/\G$grammar_regexp->{sep}/smgc || !/\G$grammar_regexp->{end}/mgc) {
        last if /\G$grammar_regexp->{end}/mgc;
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

sub _syntax_error { shift->_error('Syntax Error') }

sub _error {
    my ($class, $msg) = @_;

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
        "${msg}: line:$line",
        substr($src, $start || 0, $end - $start),
        (' ' x $len) . '^';
    die $trace, "\n";
}

1;
__END__
