#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';

use Test::Most;
use Test::Mite;

use Mite::Project;

note "Empty compile"; {
    my $project = new_ok "Mite::Project";

    lives_ok { $project->compile };
}

done_testing;
