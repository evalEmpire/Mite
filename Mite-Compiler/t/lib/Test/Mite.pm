{
    package Test::Mite;

    use v5.10;
    use strict;
    use warnings;

    use parent 'Fennec';
    use Method::Signatures;

    # Export our extra mite testing functions.
    method defaults($class: ...) {
        my %params = $class->SUPER::defaults;

        push @{ $params{utils} }, "Test::Mite::Functions";

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
    our @EXPORT = qw(mite_compile mite_load);

    use Method::Signatures;
    use Path::Tiny;
    use Child;

    func _class2pm(Str $class) {
        my $pm = $class.'.pm';
        $pm =~ s{::}{/};

        return $pm;
    }

    func mite_compile(Str $code, Str :$class, :$dir=Path::Tiny->tempdir( CLEANUP => 0 )) {
        # Write the code to a temp file
        my $pmfile = $dir->child( _class2pm($class) );
        $pmfile->spew($code);

        # Compile the code
        # Do it in its own process to avoid polluting the test process
        # with compiler code.  This better emulates how it works in production.
        my $child = Child->new(sub {
            require Mite::Project;
            my $project = Mite::Project->default;
            $project->load_files($pmfile);
            $project->write_mites;
        });
        my $process = $child->start;
        $process->wait;

        return $pmfile;
    }

    func mite_load(Str $code, Str :$class) {
        my $file = mite_compile($code, class => $class);

        # Allow the same file to be recompiled and reloaded
        return do $file;
    }

    # We're loaded, really!
    $INC{"Test/Mite/Functions.pm"} = __FILE__;
}

1;
