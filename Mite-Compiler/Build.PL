use Module::Build;

my $build = Module::Build->new(
    module_name => 'Mite',
    license  => 'perl',
    requires => {
        'perl'          => '5.8.1',
    },
);
$build->create_build_script;
