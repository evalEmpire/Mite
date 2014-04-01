#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "sim_source" => sub {
    my $source = sim_source();
    is_deeply $source->classes, {};
    ok -e $source->file;
    like $source->file, qr{\.pm$};
};

tests "sim_source with class name" => sub {
    my $source = sim_source(
        class_name      => "Foo::Bar"
    );

    like $source->file, qr{/Foo/Bar.pm$};
    is_deeply $source->classes, {};
};

tests "sim_class" => sub {
    my $class = sim_class;
    ok $class->source->has_class($class->name);
    is $class->source->class_for($class->name), $class;
};

done_testing;
