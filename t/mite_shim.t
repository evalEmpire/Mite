#!/usr/bin/env perl -w

use lib 't/lib';
use Test::Mite;

before_all "Load mite_shim" => sub {
    package mite_shim;
    require "./bin/mite_shim";
};

tests "mite_shim" => sub {
    my $shim = mite_shim::main("Foo::Bar");

    lives_ok { eval $shim };
    isa_ok("Foo::Bar", "Mite");
};

done_testing;
