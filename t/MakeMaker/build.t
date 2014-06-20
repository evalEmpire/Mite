#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use File::Copy::Recursive qw(dircopy);
use Path::Tiny;
use autodie;

my $Src_Project_Dir = 't/MakeMaker/Some-Project';
my $Original_Dir = Path::Tiny->cwd;

tests "make" => sub {
    env_for_mite();

    my $project_dir = Path::Tiny->tempdir;
    dircopy( $Src_Project_Dir, $project_dir );
    chdir $project_dir;

    mite_command("init", "Some::Project");

    system "$^X", "Makefile.PL";
    system make();

    local @INC = ("blib/lib", @INC);
    require Some::Project;
    my $obj = new_ok 'Some::Project';
    cmp_deeply $obj->something, [23, 42];

    system make(), "clean";

    ok !-e 'lib/Some/Project/Mite.pm';
    ok !-e 'lib/Some/Project.pm.mite.pm';

    path(".mite")->remove_tree;

    chdir $Original_Dir;
};

done_testing;
