package Mite::Project;

use v5.10;
use Mouse;
use Method::Signatures;
use Path::Tiny;

use Mite::Source;
use Mite::Class;

has sources =>
  is            => 'ro',
  isa           => 'HashRef[Mite::Source]',
  default       => sub { {} };

method classes() {
    return $self->sources->classes;
}

method source_for($file) {
    # Normalize the path.
    $file = path($file)->realpath;

    return $self->sources->{$file} ||= Mite::Source->new(
        file    => $file,
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
        require Mite::Attribute;
        my $attribute = Mite::Attribute->new(
            name => $name,
            %args
        );

        $class->add_attribute($attribute);

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
    for my $file (@files) {
        require $file;
    }

    return;
}

method load_directories(Defined @dirs) {
    my @files = $self->_recurse_directories(@dirs);
    $self->load_files(@files);

    return;
}

# Recursively gather all the pm files in a directory
method _recurse_directories(Defined @dirs) {
    my @pm_files;

    for my $dir (@dirs) {
        my $iter = path($dir)->iterator({ recurse => 1, follow_symlinks => 1 });

        while( my $path = $iter->() ) {
            next if -d $path;
            next unless $path =~ m{\.pm$};

            push @pm_files, $path;
        }
    }

    return @pm_files;
}

1;
