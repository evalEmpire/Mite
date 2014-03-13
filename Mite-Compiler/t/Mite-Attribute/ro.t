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
        name    => 'foo',
        is      => 'ro',
    )->compile;
}

note "Basic read-only"; {
    my $obj = new_ok 'Foo', [foo => 23];
    is $obj->foo, 23;
    throws_ok { $obj->foo("Flower child") }
        qr{foo is a read-only attribute of Foo};
}

note "Various tricky values"; {
    my $obj = new_ok 'Foo', [foo => undef];
    is $obj->foo, undef;

    $obj = new_ok 'Foo', [foo => 0];
    is $obj->foo, 0;

    $obj = new_ok 'Foo', [foo => ''];
    is $obj->foo, '';
}

done_testing;
