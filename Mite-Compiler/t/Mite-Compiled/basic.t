#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Mite;
use Path::Tiny;

use Mite::Compiled;
use Mite::Source;

tests "new" => sub {
    my $source   = Mite::Source->new( file => Path::Tiny->tempfile );
        
    my $compiled = Mite::Compiled->new(
        source => $source
    );

    is $compiled->file, $source->file . '.mite.pm';
};

tests "classes" => sub {
    my $source   = Mite::Source->new( file => Path::Tiny->tempfile );
    my $foo = $source->class_for("Foo");
    my $bar = $source->class_for("Bar");

    my $compiled = Mite::Compiled->new(
        source => $source
    );

    is_deeply [sort values %{$compiled->classes}], [sort($foo, $bar)];
};

tests "write" => sub {
    my $source   = Mite::Source->new( file => Path::Tiny->tempfile );
    my $foo = $source->class_for("Foo");
    my $bar = $source->class_for("Bar");

    my $compiled = Mite::Compiled->new(
        source => $source
    );

    $compiled->write;
    require $compiled->file;
    new_ok "Foo";
    new_ok "Bar";

    $compiled->remove;
    ok !-e $compiled->file;
};

done_testing;
