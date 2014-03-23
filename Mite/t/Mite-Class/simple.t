#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';

use Test::Most;
use Test::Mite;

use Mite::Class;
use Path::Tiny;

note "Basic mite_file handling"; {
    my $tempdir = Path::Tiny->tempdir;

    my $class = Mite::Class->new(
        name    => "Foo",
        file    => $tempdir->child("Foo.pm"),
    );

    is $class->mite_file, $tempdir->child("Foo.mite");

    ok !-e $class->mite_file;
    $class->write_mite;
    ok -e $class->mite_file;

    $class->write_mite;
    require $class->mite_file;
    new_ok "Foo";
}

done_testing;
