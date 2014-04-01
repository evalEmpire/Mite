#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "basic compilation" => sub {
    mite_load(<<'CODE');
package Foo;

use Mite;

has things =>
    default => 23;

1;
CODE

    my $obj = new_ok "Foo";
    is $obj->things, 23;
};

done_testing;
