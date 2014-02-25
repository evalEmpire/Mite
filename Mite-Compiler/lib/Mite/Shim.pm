package Mite::Shim;

use strict;
use warnings;


=head1 NAME

Mite::Shim - Lets Mite compiled classes work without having Mite installed

=head1 SYNOPSIS

    # First, make your own copy of the shim
    mite_shim 'Foo::Mite' > lib/Foo/Mite.pm

    # Then use it.
    package Foo;
    use Foo::Mite;

=head1 DESCRIPTION

This is a small module which decides if your L<Mite> code needs to be
recompiled.  It lets your code work without distributing Mite along
with it.

=cut

sub import {
    my $class = shift;
    my($caller, $file) = caller;

    # Turn on warnings and strict in the caller
    warnings->import;
    strict->import;

    my $mite_file = _mite_file(
        package         => $caller,
        filename        => $file
    );

    # Rebuild only if the original file is newer or at the same time.
    # (It's better to build twice than to miss a build)
    my $do_rebuild = (!-e $mite_file) || ((stat($file))[9] >= (stat($mite_file))[9]);

    if( $do_rebuild and eval { require Mite::Compiler } ) {
        Mite::Compiler->inject_mite_functions(
            package     => $caller,
            mite_file   => $mite_file,
        );
    }
    else {
        # Load the Mite code
        require $mite_file;

        # Inject blank Mite routines
        for my $name (qw( extends has class_has )) {
            no strict 'refs';
            *{ $caller .'::'. $name } = sub {};
        }
    }
}


sub _mite_file {
    my %args = @_;
    my $caller      = $args{package};
    my $caller_file = $args{filename};

    my $replace = '__'.$caller.'__mite.pm';
    (my $mite_file = $caller_file) =~ s{$}{$replace};

    return $mite_file;
}


sub clear_code {
    my($package, $file) = caller;

    my $mite_file = _mite_file(
        package         => $package,
        filename        => $file
    );

    1 while unlink $mite_file;

    return;
}

1;
