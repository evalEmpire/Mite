package Mite::Project;

use v5.10;
use Mouse;
use Method::Signatures;
use Path::Tiny;

use Mite::Class;

has classes =>
  is            => 'ro',
  isa           => 'HashRef[Mite::Class]',
  default       => sub { {} };

method class(:$class=caller(), :$file=(caller)[1]) {
    return $self->classes->{$class} ||= Mite::Class->new(
        name    => $class,
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

method inject_mite_functions(:$name, :$file) {
    my $class = $self->class(
        class           => $name,
        file            => $file,
    );

    no strict 'refs';
    *{ $name .'::has' } = func( $name, %args ) {
        require Mite::Attribute;
        my $attribute = Mite::Attribute->new(
            name => $name,
            %args
        );

        $class->add_attribute($attribute);

        return;
    };

    *{ $name .'::extends' } = func(@classes) {
        $class->extends(\@classes);

        return;
    };

    return;
}

method compile() {
    for my $class (values %{$self->classes}) {
        $class->compile;
    }

    return;
};

method write_mites() {
    for my $class (values %{$self->classes}) {
        $class->write_mite;
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
