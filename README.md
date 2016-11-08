[![Build Status](https://travis-ci.org/karupanerura/TOML-Parser.svg?branch=master)](https://travis-ci.org/karupanerura/TOML-Parser) [![Coverage Status](http://codecov.io/github/karupanerura/TOML-Parser/coverage.svg?branch=master)](https://codecov.io/github/karupanerura/TOML-Parser?branch=master)
# NAME

TOML::Parser - simple toml parser

# SYNOPSIS

```perl
use TOML::Parser;

my $parser = TOML::Parser->new;
my $data   = $parser->parse($toml);
```

# DESCRIPTION

TOML::Parser is a simple toml parser.

This data structure complies with the tests
provided at [https://github.com/toml-lang/toml/tree/v0.4.0/tests](https://github.com/toml-lang/toml/tree/v0.4.0/tests).

The v0.4.0 specification is supported.

# METHODS

- my $parser = TOML::Parser->new(\\%args)

    Creates a new TOML::Parser instance.

    ```perl
    use TOML::Parser;

    # create new parser
    my $parser = TOML::Parser->new();
    ```

    Arguments can be:

    - `inflate_datetime`

        If use it, You can replace inflate `datetime` process.
        The subroutine of default is `identity`. `e.g.) sub { $_[0] }`

        ```perl
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
        ```

    - `inflate_boolean`

        If use it, You can replace inflate boolean process.
        The return value of default subroutine is `Types::Serialiser::true` or `Types::Serialiser::false`.

        ```perl
        use TOML::Parser;

        # create new parser
        my $parser = TOML::Parser->new(
            inflate_boolean => sub {
                my $boolean = shift;
                return $boolean eq 'true' ? 1 : 0;
            },
        );
        ```

    - `strict_mode`

        TOML::Parser is using a more flexible rule for compatibility with old TOML of default.
        If make this option true value, You can parse a toml with strict rule.

        ```perl
        use TOML::Parser;

        # create new parser
        my $parser = TOML::Parser->new(
            strict_mode => 1
        );
        ```

- my $data = $parser->parse\_file($path)
- my $data = $parser->parse\_fh($fh)
- my $data = $parser->parse($src)

    Transforms a string containing toml to a perl data structure or vice versa.

# SEE ALSO

[TOML](https://metacpan.org/pod/TOML)

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>

# CONTRIBUTOR

Olivier Mengué <dolmen@cpan.org>
yowcow <yowcow@cpan.org>
Syohei YOSHIDA <syohex@gmail.com>
