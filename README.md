[![Build Status](https://travis-ci.org/karupanerura/TOML-Parser.png?branch=master)](https://travis-ci.org/karupanerura/TOML-Parser)
# NAME

TOML::Parser - simple toml parser

# SYNOPSIS

    use TOML::Parser;

    my $parser = TOML::Parser->new;
    my $data   = $parser->parse($toml);

# DESCRIPTION

TOML::Parser is a simple toml parser.

This data structure complies with the tests
provided at [https://github.com/mojombo/toml/tree/master/tests](https://github.com/mojombo/toml/tree/master/tests).

# WHY?

In my point of view, it's very difficult to maintain `TOML::from_toml` because -so far as I understand- there's some issues.

Specifically, for example, `TOML::from_toml` doesn't interpret correctly in some cases.
In addition, it reports wrong line number when the error occurs.
(This is because `TOML::from_toml` deletes the comments and blank lines before it parses.)

I conclude that `TOML::from_toml` has an architectural feet,
and that's why I came to an idea of re-creating another implementation in order to solve the problem.

I believe that this is much easier than taking other solutions.

# METHODS

- my $parser = TOML::Parser->new(\\%args)

    Creates a new TOML::Parser instance.

        use TOML::Parser;

        # create new parser
        my $parser = TOML::Parser->new();

    Arguments can be:

    - `inflate_datetime`

        If use it, You can replace inflate `datetime` process.

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

    - `inflate_boolean`

        If use it, You can replace inflate boolean process.

            use TOML::Parser;

            # create new parser
            my $parser = TOML::Parser->new(
                inflate_boolean => sub {
                    my $boolean = shift;
                    return $boolean eq 'true' ? 1 : 0;
                },
            );

- my $data = $parser->parse\_file($path)
- my $data = $parser->parse\_fh($fh)
- my $data = $parser->parse($src)

    Transforms a string containing toml to a perl data structure or vice versa.

# BENCHMARK

benchmark: by \`author/benchmark.pl\`

    Benchmark: timing 10000 iterations of TOML, TOML::Parser...
          TOML: 11 wallclock secs (11.11 usr +  0.02 sys = 11.13 CPU) @ 898.47/s (n=10000)
    TOML::Parser:  7 wallclock secs ( 6.84 usr +  0.01 sys =  6.85 CPU) @ 1459.85/s (n=10000)
                   Rate         TOML TOML::Parser
    TOML          898/s           --         -38%
    TOML::Parser 1460/s          62%           --

# SEE ALSO

[TOML](https://metacpan.org/pod/TOML)

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
