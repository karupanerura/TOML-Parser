requires 'Encode';
requires 'Types::Serialiser';
requires 'parent';
requires 'Exporter', '5.57';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
};

on test => sub {
    requires 'MIME::Base64';
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'JSON', '2';
    requires 'Path::Tiny';
    requires 'TOML';
};
