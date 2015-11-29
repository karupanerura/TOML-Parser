use strict;
use Test::More tests => 9;

use TOML::Parser;

eval {
    TOML::Parser->new->parse(<<'...');
foo = "bar'
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
xxx = "yyy"
foo = "bar'
...
};
like $@, qr/\ASyntax Error: line:2/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
xxx = "yyy"
# comment

# and, empty line
foo = "bar'
...
};
like $@, qr/\ASyntax Error: line:5/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[a.]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[a..b]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[.b]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[.]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
 = "no key name" # not allowed
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;
