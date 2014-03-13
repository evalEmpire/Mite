#!/usr/bin/perl

use strict;
use warnings;

use Test::Most;

use Mite::Attribute;

note "Create a class to test with"; {
    package Foo;

    sub new {
        my $class = shift;
        bless { @_ }, $class
    }

    eval Mite::Attribute->new(
        name    => 'name',
        is      => 'rw',
    )->compile;

    eval Mite::Attribute->new(
        name    => 'job',
        is      => 'rw',
    )->compile;
}

note "try various tricky values"; {
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
