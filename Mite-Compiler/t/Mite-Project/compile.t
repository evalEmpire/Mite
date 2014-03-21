#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';

use Test::Mite;

use Mite::Project;

tests "Empty compile" => sub {
    my $project = new_ok "Mite::Project";

    lives_ok { $project->compile };
};

done_testing;
