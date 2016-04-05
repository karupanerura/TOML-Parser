package t::Util;
use strict;
use warnings;

use parent qw/Test::Builder::Module/;
my $CLASS = __PACKAGE__;

use B ();
use Scalar::Util qw/looks_like_number/;
use Math::Round qw/nearest/;

our @EXPORT = qw/cmp_fuzzy_deeply/;

our $RANGE = 0.000001;

sub cmp_fuzzy_deeply ($$;$) { ## no critic
    my ($got, $expected, $msg) = @_;
    my $ok = _cmp_fuzzy_deeply($got, $expected);
    $CLASS->builder->ok($ok, $msg)
        or $CLASS->builder->diag('got: '.($CLASS->builder->explain($got))[0].$/.'expected: '.($CLASS->builder->explain($expected))[0]);
}

sub _cmp_fuzzy_deeply {
    my ($got, $expected) = @_;
    return not defined $got if not defined $expected;
    return !!0 if ref $got ne ref $expected;

    if (ref $got eq 'HASH') {
        return !!0 if keys %$got != keys %$expected;
        for my $key (keys %$expected) {
            return !!0 if not exists $got->{$key};
            return !!0 if not _cmp_fuzzy_deeply($got->{$key}, $expected->{$key});
        }
        return !!1;
    }
    elsif (ref $got eq 'ARRAY') {
        return !!0 if @$got != @$expected;
        for my $i (0..$#{$expected}) {
            return !!0 if not _cmp_fuzzy_deeply($got->[$i], $expected->[$i]);
        }
        return !!1;
    }
    elsif (looks_like_number($got) && looks_like_number($expected)) {
        # numify
        $got += 0;
        $expected += 0;

        my $flags = B::svref_2object(\$expected)->FLAGS;
        if ($flags & B::SVp_IOK & ~B::SVp_POK) {
            return $got == $expected;
        }
        elsif ($flags & B::SVp_NOK & ~B::SVp_POK) {
            return nearest($RANGE, $got) == nearest($RANGE, $expected);
        }
    }

    return $got eq $expected;
}

1;
__END__
