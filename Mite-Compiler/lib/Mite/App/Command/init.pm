package Mite::App::Command::init;

use v5.10;

use Mouse;
use MouseX::Foreign;
extends qw(Mite::App::Command);
with qw(Mite::Role::HasConfig);

use Mite::Types;
use Method::Signatures;
use Path::Tiny;
use Carp;

has project_name =>
  is            => 'rw',
  isa           => 'Str';

has source_dir =>
  is            => 'ro',
  isa           => 'Path',
  coerce        => 1,
  default       => method {
      return path("lib/");
  };

has compile_dir =>
  is            => 'ro',
  isa           => 'Path',
  coerce        => 1,
  default       => method {
      return path("lib/");
  };

has shim_name =>
  is            => 'ro',
  isa           => 'Str',
  lazy          => 1,
  default       => method {
      return $self->project_name . '::Mite';
  };

method usage_desc(...) {
    return "%c init %o <project name>";
}

method abstract() {
    return "Begin using mite with your project";
}

method validate_args($opt, $args) {
    $self->usage_error("init needs the name of your project") unless @$args;
}

method execute($opt, $args) {
    $self->project_name( shift @$args );

    $self->config->make_mite_dir;
    $self->_write_default_config if !-e $self->config->config_file;

    say sprintf "Initialized mite in %s", $self->config->mite_dir;

    return;
}

method _write_default_config() {
    $self->config->data({
        project         => $self->project_name,
        shim            => $self->shim_name,
        source_from     => $self->source_dir.'',
        compiled_to     => $self->compile_dir.'',
    });
    $self->config->write_config;

    return;
}

1;
