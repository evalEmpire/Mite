package Mite::App::Command::init;

use v5.10;
use Mouse;
use MouseX::Foreign;
extends qw(Mite::App::Command);

use Method::Signatures;
use Path::Tiny;
use Carp;

has project_name =>
  is            => 'rw',
  isa           => 'Str';

has mite_dir =>
  is            => 'ro',
  isa           => 'Path::Tiny',
  default       => method {
      return path(".mite/");
  };

has config_file =>
  is            => 'ro',
  isa           => 'Path::Tiny',
  default       => method {
      return $self->mite_dir->child("config");
  };

has source_dir =>
  is            => 'ro',
  isa           => 'Path::Tiny',
  default       => method {
      return path("lib/");
  };

has compile_dir =>
  is            => 'ro',
  isa           => 'Path::Tiny',
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

has json =>
  is            => 'rw',
  isa           => 'Object',
  default       => method {
      require JSON;
      return JSON->new->utf8(1)->pretty(1);
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

    $self->mite_dir->mkpath;
    $self->_write_config( $self->_default_config ) if !-e $self->config_file;

    say sprintf "Initialized mite in %s", $self->mite_dir;

    return;
}

method _default_config() {
    return {
        project         => $self->project_name,
        shim            => $self->shim_name,
        source_from     => $self->source_dir.'',
        compiled_to     => $self->compile_dir.'',
    };
}

method _write_config($config) {
    $self->config_file->spew_utf8( $self->json->encode($config) );
    return;
}

1;
