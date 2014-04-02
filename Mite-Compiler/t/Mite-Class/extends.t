#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "single inheritance and defaults" => sub {
    mite_load <<'CODE';
package GP1;
use Mite;
has foo =>
    default => 23;

package P1;
use Mite;
extends 'GP1';
has foo =>
    default => 42;

package C1;
use Mite;
extends 'P1';
has "bar";

1;
CODE

    my $gparent = new_ok "GP1";
    is $gparent->foo, 23;

    my $parent = new_ok "P1";
    is $parent->foo, 42;

    my $child = new_ok "C1";
    is $child->foo, 42;
};

done_testing;
