#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Mite;

tests "parents as objects" => sub {
    my $child  = sim_class;

    my(@parents) = (sim_class, sim_class);
    $child->extends([map { $_->name } @parents]);
    is_deeply $child->parents, \@parents;

    # Test parents is reset when extends is reset
    my(@new_parents) = (sim_class, sim_class);
    $child->extends([map { $_->name } @new_parents]);
    is_deeply $child->parents, \@new_parents, "YOU'RE NOT MY REAL PARENTS!!"
};

done_testing;
