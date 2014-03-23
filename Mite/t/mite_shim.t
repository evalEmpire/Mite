#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::Most;

{
    package mite_shim;
    require "./bin/mite_shim";
}

note "mite_shim"; {
    my $shim = mite_shim::main("Foo::Bar");

    lives_ok { eval $shim };
    isa_ok("Foo::Bar", "Mite");
}

done_testing;
