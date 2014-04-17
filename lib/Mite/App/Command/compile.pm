package Mite::App::Command::compile;

use feature ':5.10';
use Mouse;
use MouseX::Foreign;
extends qw(Mite::App::Command);

use Method::Signatures;
use Path::Tiny;
use Carp;

method abstract() {
    return "Make your code ready to run";
}

method execute($opt, $args) {
    require Mite::Project;
    my $project = Mite::Project->default;

    $project->add_mite_shim;
    $project->load_directory;
    $project->write_mites;

    return;
}

1;
