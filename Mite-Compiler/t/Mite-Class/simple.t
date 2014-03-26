#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';

use Test::Mite;

use Mite::Class;
use Path::Tiny;

tests "Basic mite_file handling" => sub {
    my $tempdir = Path::Tiny->tempdir;

    my $class = Mite::Class->new(
        name    => "Foo",
        file    => $tempdir->child("Foo.pm"),
    );

    is $class->mite_file, $tempdir->child("Foo.pm.mite.pmc");

    ok !-e $class->mite_file;
    $class->write_mite;
    ok -e $class->mite_file;

    $class->write_mite;
    require $class->mite_file;
    new_ok "Foo";
};

done_testing;
