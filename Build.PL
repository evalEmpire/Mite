#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Mite',
    license  => 'perl',

    requires => {
        'perl'                  => '5.10.1',
        version                 => '0.77',
        Mouse                   => '1.08',
        'Method::Signatures'    => '20140224',
        'Path::Tiny'            => '0.052',
        'App::Cmd'              => '0.323',
        'MouseX::Foreign'       => '0.008',
    },

    build_requires => {
        'Test::Sims'    => '20130412',
        'Test::Most'    => '0.31',
        'Test::Deep'    => '0.110',
        'Test::Compile' => '0.24',
        'Test::Output'  => '1.02',
        Fennec          => '2.016',
    },

    recursive_test_files => 1,

    create_license      => 1,

    meta_merge => {
        resources => {
            bugtracker => 'https://github.com/evalEmpire/Mite/issues',
            repository => 'https://github.com/evalEmpire/Mite',
        },
    }
);
$build->create_build_script;
