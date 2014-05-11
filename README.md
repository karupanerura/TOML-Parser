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

I think `TOML::from_toml` maintenance is difficult.
And, I know there are several problems with `TOML::from_toml`.

In particular, `TOML::from_toml` can not correctly interpret some cases.
And, There are cases when error occurs, where that line number is not correctly.
(Because, `TOML::from_toml` is deleting the comment and blank line before parse.)

I think `TOML::from_toml` have a problem of architecture.
I decide to re-create another implementation for solve this problem.
Because, I think that this is easier than other solution.

In Japanese:

    私はTOML::from_tomlのメンテナンスは非常に困難だと思います。
    また、私の知る限りではTOML::from_tomlにはいくつかの問題があります。

    具体的には、TOML::from_tomlはいくつかのケースで正しく解釈出来ません。
    また、エラーが起きたときに、その行数が正しく報告されません。
    （なぜなら、TOML::from_tomlはパーズの前にコメントや空行を削除しているからです。）

    TOML::from_tomlにはアーキテクチャ的な欠陥があると思います。
    私はこの問題を解決するために別の実装を作り直す事にしました。
    これが他の解決方法より簡単だと思ったからです。

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
