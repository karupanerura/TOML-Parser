package TOML::Parser::Tokenizer;
use 5.010000;
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
        multi_line_string_begin
        multi_line_string_end
        inline_table_begin
        inline_table_end
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
        table          => {
            start => qr{\[},
            key   => qr{(?:"(.*?)(?<!(?<!\\)\\)"|\'(.*?)(?<!(?<!\\)\\)\'|([^.\s\\\]]+))},
            sep   => qr{\.},
            end   => qr{\]},
        },
        array_of_table => {
            start => qr{\[\[},
            key   => qr{(?:"(.*?)(?<!(?<!\\)\\)"|\'(.*?)(?<!(?<!\\)\\)\'|([^.\s\\\]]+))},
            sep   => qr{\.},
            end   => qr{\]\]},
        },
        key            => qr{(?:"(.*?)(?<!(?<!\\)\\)"|\'(.*?)(?<!(?<!\\)\\)\'|([^\s=]+))\s*=},
        value          => {
            datetime => qr{([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?(?:Z|[-+][0-9]{2}:[0-9]{2}))},
            float    => qr{([-+]?(?:[0-9_]+(?:\.[0-9_]+)?[eE][-+]?[0-9_]+|[0-9_]*\.[0-9_]+))},
            integer  => qr{([-+]?[0-9_]+)},
            boolean  => qr{(true|false)},
            string   => qr{(?:"(.*?)(?<!(?<!\\)\\)"|\'(.*?)(?<!(?<!\\)\\)\')},
            mlstring => qr{("""|''')},
            inline   => {
                start => qr{\{},
                sep   => qr{\s*,\s*},
                end   => qr{\}},
            },
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
        elsif (/\G$grammar_regexp->{array_of_table}->{start}/mgc) {
            push @tokens => $class->_tokenize_array_of_table();
        }
        elsif (/\G$grammar_regexp->{table}->{start}/mgc) {
            push @tokens => $class->_tokenize_table();
        }
        elsif (my @t = $class->_tokenize_key_and_value()) {
            push @tokens => @t;
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

sub _tokenize_key_and_value {
    my $class = shift;
    my $grammar_regexp = $class->grammar_regexp();

    my @tokens;
    if (/\G$grammar_regexp->{key}/mgc) {
        my $key = $1 || $2 || $3;
        warn "[TOKEN] KEY: $key" if DEBUG;
        $class->_skip_whitespace();
        push @tokens => [TOKEN_KEY, $key];
        push @tokens => $class->_tokenize_value();
        return @tokens;
    }

    return;
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
    elsif (/\G$grammar_regexp->{value}->{mlstring}/mgc) {
        warn "[TOKEN] MULTI LINE STRING: $1" if DEBUG;
        return (
            [TOKEN_MULTI_LINE_STRING_BEGIN],
            $class->_extract_multi_line_string($1),
            [TOKEN_MULTI_LINE_STRING_END],
        );
    }
    elsif (/\G$grammar_regexp->{value}->{string}/mgc) {
        warn "[TOKEN] STRING: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_STRING, defined $1 ? $1 : defined $2 ? $2 : ''];
    }
    elsif (/\G$grammar_regexp->{value}->{inline}->{start}/mgc) {
        warn "[TOKEN] INLINE TABLE" if DEBUG;
        $class->_skip_whitespace();
        return (
            [TOKEN_INLINE_TABLE_BEGIN],
            $class->_tokenize_inline_table(),
            [TOKEN_INLINE_TABLE_END],
        );
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

    $class->_syntax_error();
}

sub _tokenize_table {
    my $class = shift;

    my $grammar_regexp = $class->grammar_regexp()->{table};
    warn "[CALL] _tokenize_table" if DEBUG;

    $class->_skip_whitespace();

    my @expected = ($grammar_regexp->{key});

    my @keys;
 LOOP:
    while (1) {
        for my $rx (@expected) {
            if (/\G$rx/smgc) {
                if ($rx eq $grammar_regexp->{key}) {
                    my $key = $1 || $2 || $3;
                    warn "[TOKEN] table key: $key" if DEBUG;
                    push @keys => $key;
                    @expected = ($grammar_regexp->{sep}, $grammar_regexp->{end});
                }
                elsif ($rx eq $grammar_regexp->{sep}) {
                    warn "[TOKEN] table key separator" if DEBUG;
                    @expected = ($grammar_regexp->{key});
                }
                elsif ($rx eq $grammar_regexp->{end}) {
                    warn "[TOKEN] table key end" if DEBUG;
                    @expected = ();
                    last LOOP;
                }
                $class->_skip_whitespace();
                next LOOP;
            }
        }

        $class->_syntax_error();
    }

    warn "[TOKEN] TABLE: @{[ join '.', @keys ]}" if DEBUG;
    return [TOKEN_TABLE, \@keys];
}

sub _tokenize_array_of_table {
    my $class = shift;

    my $grammar_regexp = $class->grammar_regexp()->{array_of_table};
    warn "[CALL] _tokenize_array_of_table" if DEBUG;

    $class->_skip_whitespace();

    my @expected = ($grammar_regexp->{key});

    my @keys;
 LOOP:
    while (1) {
        for my $rx (@expected) {
            if (/\G$rx/smgc) {
                if ($rx eq $grammar_regexp->{key}) {
                    my $key = $1 || $2 || $3;
                    warn "[TOKEN] table key: $key" if DEBUG;
                    push @keys => $key;
                    @expected = ($grammar_regexp->{sep}, $grammar_regexp->{end});
                }
                elsif ($rx eq $grammar_regexp->{sep}) {
                    warn "[TOKEN] table key separator" if DEBUG;
                    @expected = ($grammar_regexp->{key});
                }
                elsif ($rx eq $grammar_regexp->{end}) {
                    warn "[TOKEN] table key end" if DEBUG;
                    @expected = ();
                    last LOOP;
                }
                $class->_skip_whitespace();
                next LOOP;
            }
        }

        $class->_syntax_error();
    }

    warn "[TOKEN] ARRAY_OF_TABLE: @{[ join '.', @keys ]}" if DEBUG;
    return [TOKEN_ARRAY_OF_TABLE, \@keys];
}

sub _extract_multi_line_string {
    my ($class, $delimiter) = @_;
    if (/\G(.+?)\Q$delimiter/smgc) {
        warn "[TOKEN] MULTI LINE STRING: $1" if DEBUG;
        $class->_skip_whitespace();
        return [TOKEN_STRING, $1];
    }
    $class->_syntax_error();
}

sub _tokenize_inline_table {
    my $class = shift;

    my $common_grammar_regexp = $class->grammar_regexp();
    my $grammar_regexp = $common_grammar_regexp->{value}->{inline};

    warn "[CALL] _tokenize_inline_table" if DEBUG;
    return if /\G(?:$grammar_regexp->{sep})?$grammar_regexp->{end}/smgc;

    my $need_sep = 0;

    my @tokens;
    while (1) {
        warn "[CONTEXT] _tokenize_inline_table [loop]" if DEBUG;

        $class->_skip_whitespace();
        if (/\G$common_grammar_regexp->{comment}/mgc) {
            warn "[TOKEN] COMMENT: $1" if DEBUG;
            push @tokens => [TOKEN_COMMENT, $1 || ''];
            next;
        }
        elsif (/\G$grammar_regexp->{end}/mgc) {
            last;
        }

        if ($need_sep) {
            if (/\G$grammar_regexp->{sep}/smgc) {
                $need_sep = 0;
                next;
            }
        }
        else {
            if (my @t = $class->_tokenize_key_and_value()) {
                push @tokens => @t;
                $need_sep = 1;
                next;
            }
        }

        $class->_syntax_error();
    }

    return @tokens;
}

sub _tokenize_array {
    my $class = shift;

    my $common_grammar_regexp = $class->grammar_regexp();
    my $grammar_regexp = $common_grammar_regexp->{value}->{array};

    warn "[CALL] _tokenize_array" if DEBUG;
    return if /\G(?:$grammar_regexp->{sep})?$grammar_regexp->{end}/smgc;

    my $need_sep = 0;

    my @tokens;
    while (1) {
        warn "[CONTEXT] _tokenize_inline_table [loop]" if DEBUG;

        $class->_skip_whitespace();
        if (/\G$common_grammar_regexp->{comment}/mgc) {
            warn "[TOKEN] COMMENT: $1" if DEBUG;
            push @tokens => [TOKEN_COMMENT, $1 || ''];
            next;
        }
        elsif (/\G$grammar_regexp->{end}/mgc) {
            last;
        }

        if ($need_sep) {
            if (/\G$grammar_regexp->{sep}/smgc) {
                $need_sep = 0;
                next;
            }
        }
        else {
            if (my @t = $class->_tokenize_value()) {
                push @tokens => @t;
                $need_sep = 1;
                next;
            }
        }

        $class->_syntax_error();
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
    my $end = pos $src;
    my $len = pos() - $start;
    $len-- if $len > 0;

    my $trace = join "\n",
        "${msg}: line:$line",
        substr($src, $start || 0, $end - $start),
        (' ' x $len) . '^';
    die $trace, "\n";
}

1;
__END__
