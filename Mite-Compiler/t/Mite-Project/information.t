#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use lib 't/lib';

use Test::Mite;

use Mite::Project;

tests "class() and source()" => sub {
    my $project = Mite::Project->new;

    my @sources = (sim_source, sim_source);
    $project->add_sources(@sources);

    my @classes = (
        $sources[0]->class_for(rand_class_name),
        $sources[1]->class_for(rand_class_name),
        $sources[1]->class_for(rand_class_name)
    );

    cmp_deeply $project->classes, {
        map { ($_->name, $_) } @classes
    };

    for my $class (@classes) {
        is $project->class($class->name), $class;
    }

    for my $source (@sources) {
        is $project->source($source->file), $source;
    }
};

done_testing;
