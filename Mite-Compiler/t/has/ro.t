#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::Most;

note "making test class"; {
    package Foo;

    use Mite::Shim;

    has name => (
        is      => 'ro',
    );

    has job => (
        is      => 'ro',
        default => "Unemployed"
    );

    # Sometimes delete the compile code, to test the compiled code.
    END { Mite::Shim::clear_code if int rand 2; }
}


note "basic object creation and accessors"; {
    my $obj = Foo->new(
        name    => "Yarrow Hock"
    );

    is $obj->name, "Yarrow Hock", "attribute from new";

    TODO: {
        local $TODO = "Implement defaults";
        is $obj->job,  "Unemployed",  "attribute not defined in new with default";
    }

    throws_ok
      { $obj->job("Flower child") }
      qr{job is a read-only attribute of Foo};
}

done_testing;
