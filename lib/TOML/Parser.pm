package TOML::Parser;
use 5.008005;
use strict;
use warnings;
use utf8;
use Encode;

our $VERSION = "0.01";

use TOML::Parser::Tokenizer qw/:constant/;
use TOML::Parser::Util qw/unescape_str/;
use Types::Serialiser;

sub new {
    my $class = shift;
    my $args  = (@_ == 1 and ref $_[0] eq 'HASH') ? +shift : +{ @_ };
    return bless +{
        inflate_datetime => sub { $_[0] },
        inflate_boolean  => sub { $_[0] eq 'true' ? Types::Serialiser::true : Types::Serialiser::false },
        %$args,
    } => $class;
}

sub parse_file {
    my ($self, $file) = @_;
    open my $fh, '<:encoding(utf-8)', $file or die $!;
    return $self->parse_fh($fh);
}

sub parse_fh {
    my ($self, $fh) = @_;
    my $src = do { local $/; <$fh> };
    return $self->parse($src);
}

our @TOKENS;
our $ROOT;
our $CONTEXT;
sub parse {
    my ($self, $src) = @_;

    local $ROOT    = {};
    local $CONTEXT = $ROOT;
    local @TOKENS  = TOML::Parser::Tokenizer->tokenize($src);
    return $self->_parse_tokens();
}

sub _parse_tokens {
    my $self = shift;

    while (my $token = shift @TOKENS) {
        my ($type, $pos, $val) = @$token;
        if ($type eq TOKEN_TABLE) {
            $self->_parse_table($val);
        }
        elsif ($type eq TOKEN_ARRAY_OF_TABLE) {
            $self->_parse_array_of_table($val);
        }
        elsif ($type eq TOKEN_KEY) {
            my $token = shift @TOKENS;
            $CONTEXT->{$val} = $self->_parse_value_token($token);
        }
        elsif ($type eq TOKEN_COMMENT) {
            # pass through
        }
        else {
            die "Unknown case. type:$type";
        }
    }

    return $CONTEXT;
}

sub _parse_table {
    my ($self, $key) = @_;

    local $CONTEXT = $ROOT;
    for my $k (split /\./, $key) {
        if (exists $CONTEXT->{$k}) {
            $CONTEXT = ref $CONTEXT->{$k} eq 'ARRAY' ? $CONTEXT->{$k}->[-1] :
                       ref $CONTEXT->{$k} eq 'HASH'  ? $CONTEXT->{$k}       :
                       die "invalid structure. $key cannot be `Table`";
        }
        else {
            $CONTEXT = $CONTEXT->{$k} ||= +{};
        }
    }

    $self->_parse_tokens();
}

sub _parse_array_of_table {
    my ($self, $key) = @_;
    my @keys     = split /\./, $key;
    my $last_key = pop @keys;

    local $CONTEXT = $ROOT;
    for my $k (@keys) {
        if (exists $CONTEXT->{$k}) {
            $CONTEXT = ref $CONTEXT->{$k} eq 'ARRAY' ? $CONTEXT->{$k}->[-1] :
                       ref $CONTEXT->{$k} eq 'HASH'  ? $CONTEXT->{$k}       :
                       die "invalid structure. $key cannot be `Array of table`.";
        }
        else {
            $CONTEXT = $CONTEXT->{$k} ||= +{};
        }
    }

    $CONTEXT->{$last_key} = [] unless exists $CONTEXT->{$last_key};
    die "invalid structure. $key cannot be `Array of table`" unless ref $CONTEXT->{$last_key} eq 'ARRAY';
    push @{ $CONTEXT->{$last_key} } => $CONTEXT = {};

    $self->_parse_tokens();
}

sub _parse_value_token {
    my $self  = shift;
    my $token = shift;

    my ($type, $pos, $val) = @$token;
    if ($type eq TOKEN_COMMENT) {
        return; # pass through
    }
    elsif ($type eq TOKEN_INTEGER || $type eq TOKEN_FLOAT) {
        return 0+$val;
    }
    elsif ($type eq TOKEN_BOOLEAN) {
        return $self->inflate_boolean($val);
    }
    elsif ($type eq TOKEN_DATETIME) {
        return $self->inflate_datetime($val);
    }
    elsif ($type eq TOKEN_STRING) {
        return unescape_str($val);
    }
    elsif ($type eq TOKEN_ARRAY_BEGIN) {
        my @data;
        while (my $token = shift @TOKENS) {
            last if $token->[0] eq TOKEN_ARRAY_END;
            push @data => $self->_parse_value_token($token);
        }
        return \@data;
    }
    else {
        die "Unknown case. type:$type";
    }
}

sub inflate_datetime {
    my $self = shift;
    return $self->{inflate_datetime}->(@_);
}

sub inflate_boolean {
    my $self = shift;
    return $self->{inflate_boolean}->(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

TOML::Parser - simple toml parser

=head1 SYNOPSIS

    use TOML::Parser;

    my $parser = TOML::Parser->new;
    my $data   = $parser->parse($toml);

=head1 DESCRIPTION

TOML::Parser is a simple toml parser.

This data structure complies with the tests
provided at L<https://github.com/mojombo/toml/tree/master/tests>.

=head1 WHY?

In my point of view, it's very difficult to maintain C<TOML::from_toml> because -so far as I understand- there's some issues.

Specifically, for example, C<TOML::from_toml> doesn't interpret correctly in some cases.
In addition, it reports wrong line number when the error occurs.
(This is because C<TOML::from_toml> deletes the comments and blank lines before it parses.)

I conclude that C<TOML::from_toml> has an architectural feet,
and that's why I came to an idea of re-creating another implementation in order to solve the problem.

I believe that this is much easier than taking other solutions.

=head1 METHODS

=over

=item my $parser = TOML::Parser->new(\%args)

Creates a new TOML::Parser instance.

    use TOML::Parser;

    # create new parser
    my $parser = TOML::Parser->new();

Arguments can be:

=over

=item * C<inflate_datetime>

If use it, You can replace inflate C<datetime> process.

    use TOML::Parser;
    use DateTime;
    use DateTime::Format::ISO8601;

    # create new parser
    my $parser = TOML::Parser->new(
        inflate_datetime => sub {
            my $dt = shift;
            return DateTime::Format::ISO8601->parse_datetime($dt);
        },
    );

=item * C<inflate_boolean>

If use it, You can replace inflate boolean process.

    use TOML::Parser;

    # create new parser
    my $parser = TOML::Parser->new(
        inflate_boolean => sub {
            my $boolean = shift;
            return $boolean eq 'true' ? 1 : 0;
        },
    );

=back

=item my $data = $parser->parse_file($path)

=item my $data = $parser->parse_fh($fh)

=item my $data = $parser->parse($src)

Transforms a string containing toml to a perl data structure or vice versa.

=back

=head1 BENCHMARK

benchmark: by `author/benchmark.pl`

    Benchmark: timing 10000 iterations of TOML, TOML::Parser...
          TOML: 11 wallclock secs (11.11 usr +  0.02 sys = 11.13 CPU) @ 898.47/s (n=10000)
    TOML::Parser:  7 wallclock secs ( 6.84 usr +  0.01 sys =  6.85 CPU) @ 1459.85/s (n=10000)
                   Rate         TOML TOML::Parser
    TOML          898/s           --         -38%
    TOML::Parser 1460/s          62%           --

=head1 SEE ALSO

L<TOML>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

