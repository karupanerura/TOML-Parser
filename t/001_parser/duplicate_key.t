use strict;
use Test::More tests => 6;

use TOML::Parser;

eval {
    TOML::Parser->new->parse(<<'...');
foo  = "foo"
hoge = "fuga"
...
};
is $@, '', 'should live when another key';

eval {
    TOML::Parser->new->parse(<<'...');
foo  = "foo"
hoge = "fuga"

[bar]
foo  = "foo"
hoge = "fuga"

[baz]
foo  = "foo"
hoge = "fuga"
...
};
is $@, '', 'should live when another table';

eval {
    TOML::Parser->new->parse(<<'...');
foo  = "foo"
hoge = "fuga"

[[bar]]
foo  = "foo"
hoge = "fuga"

[[bar]]
foo  = "foo"
hoge = "fuga"
...
};
is $@, '', 'should live when another array of table';

eval {
    my $data = TOML::Parser->new->parse(<<'...');
foo = "foo"
foo = "foo"
...
    note explain $data;
};
like $@, qr/^\QDuplicate key. key:foo/, 'should die when same key';

eval {
    my $data = TOML::Parser->new->parse(<<'...');
foo = "foo"
hoge = "fuga"

[bar]
foo = "foo"
foo = "foo"

[baz]
foo = "foo"
hoge = "fuga"
...
    note explain $data;
};
like $@, qr/^\QDuplicate key. key:foo/, 'should die when same key in table';

eval {
    my $data = TOML::Parser->new->parse(<<'...');
foo = "foo"
hoge = "fuga"

[[bar]]
foo = "foo"
foo = "foo"

[[bar]]
foo = "foo"
hoge = "fuga"
...
    note explain $data;
};
like $@, qr/^\QDuplicate key. key:foo/, 'should die when same key in array of table';
