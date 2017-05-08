requires 'Encode';
requires 'Exporter', '5.57';
requires 'Types::Serialiser';
requires 'parent';
requires 'perl', '5.010000';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'MIME::Base64';
    requires 'Storable', '2.38';
    requires 'Test::Deep';
    requires 'Test::Deep::Fuzzy';
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'JSON', '2';
    requires 'Path::Tiny';
    requires 'TOML';
};
