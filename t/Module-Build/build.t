#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use Path::Tiny;
use autodie;

tests "Build" => sub {
    my $libdir = path("lib")->absolute;
    my $bindir = path("bin")->absolute;

    local $ENV{PATH}     = join ':', grep { defined } $bindir, $ENV{PATH};
    local $ENV{PERL5LIB} = join ':', grep { defined } $libdir, $ENV{PERL5LIB};

    chdir 't/Module-Build/Some-Project';

    mite_command("init", "Some::Project");

    system "$^X", "Build.PL";
    system './Build';

    local @INC = ("lib", @INC);
    require Some::Project;
    my $obj = new_ok 'Some::Project';
    cmp_deeply $obj->something, [23, 42];

    system './Build', "clean";

    ok !-e 'lib/Some/Project/Mite.pm';
    ok !-e 'lib/Some/Project.pm.mite.pm';

    path(".mite")->remove_tree;
};

done_testing;
