package Mite::Project;

use v5.10;
use Mouse;
with qw(Mite::Role::HasConfig);

use Method::Signatures;
use Path::Tiny;

use Mite::Source;
use Mite::Class;

has sources =>
  is            => 'ro',
  isa           => 'HashRef[Mite::Source]',
  default       => sub { {} };

method classes() {
    my %classes = map { %{$_->classes} }
                  values %{$self->sources};
    return \%classes;
}

# Careful not to create a class.
method class($name) {
    return $self->classes->{$name};
}

# Careful not to create a source.
method source($file) {
    return $self->sources->{$file};
}

method add_sources(@sources) {
    for my $source (@sources) {
        $self->sources->{$source->file} = $source;
    }
}

method source_for($file) {
    # Normalize the path.
    $file = path($file)->realpath;

    return $self->sources->{$file} ||= Mite::Source->new(
        file    => $file,
        project => $self
    );
}

# Get/set the default Mite project
method default($class: $new_default?) {
    return $class->projects("Default" => $new_default);
}

# Get/set the named project
method projects($class: $name, $project?) {
    state $projects = {};

    return $project ? $projects->{$name} = $project
                    : $projects->{$name} ||= $class->new;
}

# This is the shim Mite.pm uses when compiling.
method inject_mite_functions(:$package, :$file) {
    my $source = $self->source_for($file);
    my $class  = $source->class_for($package);

    no strict 'refs';
    *{ $package .'::has' } = func( $name, %args ) {
        if( my $is_extension = $name =~ s{^\+}{} ) {
            $class->extend_attribute(
                name    => $name,
                %args
            );
        }
        else {
            require Mite::Attribute;
            my $attribute = Mite::Attribute->new(
                name    => $name,
                %args
            );
            $class->add_attribute($attribute);
        }

        return;
    };

    *{ $package .'::extends' } = func(@classes) {
        $class->extends(\@classes);

        return;
    };

    return;
}

method write_mites() {
    for my $source (values %{$self->sources}) {
        $source->compiled->write;
    }

    return;
}

method load_files(Defined @files) {
    local $ENV{MITE_COMPILE} = 1;
    local @INC = (".", @INC);
    for my $file (@files) {
        require $file;
    }

    return;
}

method find_pms($dir=$self->config->data->{source_from}) {
    return $self->_recurse_directory(
        $dir,
        func($path) {
            return if -d $path;
            return unless $path =~ m{\.pm$};
            return if $path =~ m{\.mite\.pm$};
            return 1;
        }
    );
}

method load_directory($dir=$self->config->data->{source_from}) {
    $self->load_files( $self->find_pms($dir) );

    return;
}

method find_mites($dir=$self->config->data->{compiled_to}) {
    return $self->_recurse_directory(
        $dir,
        func($path) {
            return if -d $path;
            return 1 if $path =~ m{\.mite\.pm$};
            return;
        }
    );
}

method clean_mites($dir=$self->config->data->{compiled_to}) {
    for my $file ($self->find_mites($dir)) {
        path($file)->remove;
    }

    return;
}

# Recursively gather all the pm files in a directory
method _recurse_directory(Str $dir, CodeRef $check) {
    my @pm_files;

    my $iter = path($dir)->iterator({ recurse => 1, follow_symlinks => 1 });
    while( my $path = $iter->() ) {
        next unless $check->($path);
        push @pm_files, $path;
    }

    return @pm_files;
}

1;
