package Mite::App::Command::compile;

use v5.10;
use Mouse;
use MouseX::Foreign;
extends qw(Mite::App::Command);
with 'Mite::Role::HasConfig';

use Method::Signatures;
use Path::Tiny;
use Carp;

method abstract() {
    return "Make your code ready to run";
}

method execute($opt, $args) {
    require Mite::Project;
    my $project = Mite::Project->default;
    $project->load_directories( $self->config->data->{source_from} );
    $project->write_mites;

    return;
}

1;
