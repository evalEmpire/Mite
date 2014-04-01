{
    package Test::Mite;

    use v5.10;
    use strict;
    use warnings;

    use parent 'Fennec';
    use Method::Signatures;

    # func, not a method, to avoid altering @_
    func import(...) {
        # Turn on strict, warnings and 5.10 features
        strict->import;
        warnings->import;
        require feature;
        feature->import(":5.10");

        goto &Fennec::import;
    }

    # Export our extra mite testing functions.
    method defaults($class: ...) {
        my %params = $class->SUPER::defaults;

        push @{ $params{utils} }, "Test::Mite::Functions", "Test::Deep";

        return %params;
    }

    # Test with and without Class::XSAccessor.
    method after_import($class: $info) {
        # Test the pure Perl implementation.
        $info->{layer}->add_case(
            [$info->{importer}, __FILE__, __LINE__ + 1],
            case_pure_perl => func(...) {
                $ENV{MITE_PURE_PERL} = 1;
            }
        );

        # Test with Class::XSAccessor, if available.
        $info->{layer}->add_case(
            [$info->{importer}, __FILE__, __LINE__ + 1],
            case_xs => func(...) {
                $ENV{MITE_PURE_PERL} = 0;
            }
        ) if eval { require Class::XSAccessor };
    }
}


# Because of the way Fennec works, it's easier to put
# all our extra functions into their on class.
{
    package Test::Mite::Functions;

    use v5.10;
    use strict;
    use warnings;

    use parent 'Exporter';
    our @EXPORT = qw(
        mite_compile mite_load
        sim_source sim_class sim_project
        rand_class_name
    );

    use Test::Sims;
    use Method::Signatures;
    use Path::Tiny;
    use Child;

    use utf8;
    make_rand class_word => [qw(
        Foo bar __9 h1N1 ünicode
    )];

    my $max_class_words = 5;
    make_rand class_name => func() {
        state $used_classes = {};

        my $num_words = (int rand $max_class_words) + 1;
        return join "::", map { rand_class_word() } (1..$num_words);
    };

    # Because some things are stored as weak refs, automatically created
    # sim objects can be deallocated if we don't hold a reference to them.
    func _store_obj(Object $obj) {
        state $storage = [];

        push @$storage, $obj;

        return $obj;
    }

    func sim_class(%args) {
        $args{name}   //= rand_class_name();
        $args{source} //= _store_obj( sim_source(
            class_name  => $args{name}
        ));

        return $args{source}->class_for($args{name});
    }

    func sim_source(%args) {
        # Keep all the sources in one directory simulating a
        # project library directory
        state $source_dir = Path::Tiny->tempdir;

        my $class_name = delete $args{class_name} || rand_class_name();

        my $default_file = $source_dir->child(_class2pm($class_name));
        $default_file->parent->mkpath;
        $default_file->touch;
        $args{file} //= $default_file;

        $args{project} //= _store_obj(sim_project());

        return $args{project}->source_for($args{file});
    }

    func sim_project(%args) {
        require Mite::Project;
        return Mite::Project->new;
    }

    func _class2pm(Str $class) {
        my $pm = $class.'.pm';
        $pm =~ s{::}{/}g;

        return $pm;
    }

    func mite_compile(Str $code) {
        # Write the code to a temp file, make sure it survives this routine.
        my $file = Path::Tiny->tempfile( UNLINK => 0 );
        $file->spew_utf8($code);

        # Compile the code
        # Do it in its own process to avoid polluting the test process
        # with compiler code.  This better emulates how it works in production.
        my $child = Child->new(sub {
            require Mite::Project;
            my $project = Mite::Project->default;
            $project->load_files($file);
            $project->write_mites;
        });
        my $process = $child->start;
        $process->wait;

        return $file;
    }

    func mite_load(Str $code) {
        my $file = mite_compile($code);

        # Allow the same file to be recompiled and reloaded
        return do $file;
    }

    # We're loaded, really!
    $INC{"Test/Mite/Functions.pm"} = __FILE__;
}

1;
