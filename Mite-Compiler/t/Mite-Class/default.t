#!/usr/bin/perl

use strict;
use warnings;

use Test::Most;

use Path::Tiny;
use Mite::Class;
use Mite::Attribute;

note "Create a class to test with"; {
    my $class = Mite::Class->new(
        name            => 'Foo',
        file            => Path::Tiny->tempfile,
    );

    $class->add_attributes(
        Mite::Attribute->new(
            name    => 'name',
            is      => 'ro',
            default => "Yarrow Hock",
        ),
        Mite::Attribute->new(
            name    => 'howmany',
            is      => 'rw',
            default => 0,
        ),
    );

    eval $class->compile or die $@;
}

note "Defaults"; {
    my $obj = new_ok "Foo";
    is $obj->name, "Yarrow Hock";
    is $obj->howmany, 0;
}

done_testing;
