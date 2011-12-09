#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

note "making test class"; {
    package Foo;

    use Mite::Shim;

    has "name";
    has "job";

    # Sometimes delete the compile code, to test the compiled code.
    END { Mite::Shim::clear_code if int rand 2; }
}


note "basic object creation and accessors"; {
    my $obj = Foo->new(
        name    => "Yarrow Hock"
    );

    is $obj->name, "Yarrow Hock", "attribute from new";
    is $obj->job,  undef,         "attribute not defined in new";

    $obj->job("Flower child");
    is $obj->job, "Flower child", "set attribute";

    $obj->name("Foo Bar");
    is $obj->name, "Foo Bar",     "change attribute";

    $obj->name(undef);
    is $obj->name, undef,         "set to undef";

    $obj->name(0);
    is $obj->name, 0,             "set to 0";

    $obj->name("");
    is $obj->name, "",            "set to empty string";
}

done_testing;
