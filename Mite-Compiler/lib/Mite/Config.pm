package Mite::Config;

use v5.10;

use Mouse;
with qw(Mite::Role::HasYAML);

use Mite::Types;
use Path::Tiny;
use Method::Signatures;
use Carp;

has mite_dir_name =>
  is            => 'ro',
  isa           => 'Str',
  default       => '.mite';

has mite_dir =>
  is            => 'ro',
  isa           => 'Path',
  coerce        => 1,
  lazy          => 1,
  default       => method {
      return $self->find_mite_dir ||
        croak "No @{[$self->mite_dir_name]} directory found";
  };

has config_file =>
  is            => 'ro',
  isa           => 'Path',
  coerce        => 1,
  lazy          => 1,
  default       => method {
      return $self->mite_dir->child("config");
  };

has data =>
  is            => 'rw',
  isa           => 'HashRef',
  lazy          => 1,
  default       => method {
      return $self->yaml_load( $self->config_file->slurp_utf8 );
  };

method make_mite_dir($dir=Path::Tiny->cwd) {
    return path($dir)->child($self->mite_dir_name)->mkpath;
}

method write_config() {
    $self->config_file->spew_utf8( $self->yaml_dump( $self->data ) );
    return;
}

method find_mite_dir($current=Path::Tiny->cwd) {
    my $mite_dir_name = $self->mite_dir_name;

    for(
        ;
        !$current->is_rootdir;
        $current = $current->parent
    ) {
        my $maybe_mite = $current->child($mite_dir_name);
        return $maybe_mite if -d $maybe_mite;
    }

    return;
}

1;
