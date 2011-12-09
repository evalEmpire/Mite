#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Mite',
    license  => 'perl',

    requires => {
        'perl'          => '5.8.1',
        parent          => '0.217',
        version         => '0.77',
    },

    build_requires => {
        'Test::More'    => '0.88',
    },

    create_license      => 1,
    create_readme       => 1,
);
$build->create_build_script;
