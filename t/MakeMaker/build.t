#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use Path::Tiny;
use autodie;

tests "make" => sub {
    chdir 't/MakeMaker/Some-Project';

    mite_command("init", "Some::Project");

    system "$^X", "Makefile.PL";
    system make();

    local @INC = ("lib", @INC);
    require Some::Project;
    my $obj = new_ok 'Some::Project';
    cmp_deeply $obj->something, [23, 42];

    system make(), "clean";

    ok !-e 'lib/Some/Project/Mite.pm';
    ok !-e 'lib/Some/Project.pm.mite.pm';

    path(".mite")->remove_tree;
};

done_testing;
