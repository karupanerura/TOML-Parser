requires 'Encode';
requires 'Types::Serialiser';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
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
