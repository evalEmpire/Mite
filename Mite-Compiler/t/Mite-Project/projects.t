#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';

use Test::Most;
use Test::Mite;

use Mite::Project;

note "Get the default project"; {
    my $project = Mite::Project->default;
    isa_ok $project, "Mite::Project";

    is( Mite::Project->default, $project, "same default" );

    my $new_project = new_ok "Mite::Project";
    Mite::Project->default($new_project);
    is( Mite::Project->default, $new_project, "changed default" );    
}

done_testing;
