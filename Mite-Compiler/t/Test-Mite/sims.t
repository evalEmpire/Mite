#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use lib 't/lib';

use Test::Mite;

tests "sim_source" => sub {
    my $source = sim_source();
    is_deeply $source->classes, {};
    ok -e $source->file;
};

tests "sim_source with classes" => sub {
    require Mite::Class;
    my $class = Mite::Class->new(
        name => "Foo::Bar"
    );

    my $source = sim_source(
        classes => { "Foo::Bar" => $class }
    );

    like $source->file, qr{/Foo/Bar.pm$};
    is $source->classes->{"Foo::Bar"}->source, $source;
};

done_testing;
