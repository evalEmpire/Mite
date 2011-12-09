#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

note "making a test class"; {
    package Foo;
    use Mite::Shim;

    # Sometimes delete the compile code, to test the compiled code.
    END { Mite::Shim::clear_code if int rand 2; }
}


note "basic new()"; {
    my $obj = Foo->new;
    isa_ok $obj, "Foo";
}

done_testing;
