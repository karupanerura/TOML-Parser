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
    requires 'Test::More';
};

on develop => sub {
    requires 'File::Slurp';
    requires 'JSON', '2';
    requires 'TOML';
};