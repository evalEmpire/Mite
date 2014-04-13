#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "Path" => sub {
    {
        package Foo;
        use Mouse;
        use Mite::Types;

        has file =>
          is    => 'rw',
          isa   => 'Path',
          coerce => 1;
    }

    my $obj = new_ok 'Foo';
    $obj->file("/foo/bar");
    isa_ok $obj->file, "Path::Tiny";
    is $obj->file, "/foo/bar";

    $obj->file( Path::Tiny->new("woof") );
    isa_ok $obj->file, "Path::Tiny";
    is $obj->file, "woof";
};

done_testing;
