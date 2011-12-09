#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

note "mite_shim"; {
    my $shim = `$^X "-Ilib" bin/mite_shim Foo::Bar`;

    like $shim, qr/package Foo::Bar/;
}

done_testing;
