#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Path::Tiny;
use autodie;

use Mite::Config;

tests "find_mite_dir with no .mite dir" => sub {
    my $dir = Path::Tiny->tempdir;

    my $config = new_ok 'Mite::Config';
    my $mite_dir = $config->find_mite_dir($dir);
    if( $mite_dir ) {
        isnt $mite_dir, $dir;
    }
    else {
        pass;
    }
};

tests "make_mite_dir twice" => sub {
    my $dir = Path::Tiny->tempdir;
    my $config = new_ok "Mite::Config";
    ok $config->make_mite_dir($dir);
    ok -d $dir->child($config->mite_dir_name);
    ok !$config->make_mite_dir($dir);
};

tests "find_mite_dir" => sub {
    my $dir = Path::Tiny->tempdir;
    my $subdir = $dir->child("inner");
    $subdir->mkpath;

    my $config = new_ok 'Mite::Config';
    ok $config->make_mite_dir($dir);

    is $config->find_mite_dir($dir),    $dir->child($config->mite_dir_name);
    is $config->find_mite_dir($subdir), $dir->child($config->mite_dir_name);
};


done_testing;
