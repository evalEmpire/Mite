#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "undef default" => sub {
    mite_load <<'CODE';
package Foo;
use Mite;

has foo =>
    default => undef;

1;
CODE

    my $obj = new_ok "Foo";
    is $obj->foo, undef;
};

done_testing;
