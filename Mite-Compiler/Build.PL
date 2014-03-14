#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Mite::Compiler',
    license  => 'perl',

    requires => {
        'perl'                  => '5.10.1',
        version                 => '0.77',
        Mite                    => '0.0.1',
        Mouse                   => '1.08',
        'Method::Signatures'    => '20140224',
        'Path::Tiny'            => '0.052',
    },

    build_requires => {
        'Test::Most'    => '0.31',
        'Test::Compile' => '0.24',
    },

    recursive_test_files => 1,

    create_license      => 1,
    create_readme       => 1,
);
$build->create_build_script;
