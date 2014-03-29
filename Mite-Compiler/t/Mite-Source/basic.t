#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Mite;
use Path::Tiny;

use Mite::Source;

tests "class_for" => sub {
    my $source = Mite::Source->new( file => Path::Tiny->tempfile );

    my $foo = $source->class_for("Foo");
    my $bar = $source->class_for("Bar");

    is $foo->source, $source;
    is $bar->source, $source;

    isnt $foo, $bar;
    is $foo, $source->class_for("Foo"), "classes are cached";
    is $bar, $source->class_for("Bar"), "  double check that";

    ok $source->has_class("Foo");
    ok $source->has_class("Bar");
    ok !$source->has_class("Baz");
};

tests "compiled" => sub {
    my $source = Mite::Source->new( file => Path::Tiny->tempfile );
    my $compiled = $source->compiled;

    isa_ok $compiled, "Mite::Compiled";
    is $compiled->source, $source;

    is $source->compiled, $compiled, "compiled is cached";
};

done_testing;
