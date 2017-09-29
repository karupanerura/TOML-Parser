use strict;
use Test::More tests => 18;

use TOML::Parser;

eval {
    TOML::Parser->new->parse(<<'...');
foo
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

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

eval {
    TOML::Parser->new->parse(<<'...');
[[]]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[[a.]]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[[a..b]]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[[.b]]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
[[.]]
...
};
like $@, qr/\ASyntax Error: line:1/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
key = """
  never ending
  multi line string
...
};
like $@, qr/\ASyntax Error: line:2/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
inline-table = {
   key1 = "If no comma after key/value pair",
   key2 = "Should failed the test"
   key3 = "this inline table's syntax is wrong (detect syntax error on this line)"
}
...
};
like $@, qr/\ASyntax Error: line:4/m, 'detect syntax error' or diag $@;

eval {
    TOML::Parser->new->parse(<<'...');
array = [
   "If no comma after value",
   "Should failed the test"
   "this array's syntax is wrong (detect syntax error on this line)"
}
...
};
like $@, qr/\ASyntax Error: line:4/m, 'detect syntax error' or diag $@;
