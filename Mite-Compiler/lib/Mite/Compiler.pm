package Mite::Compiler;

use strict;
use warnings;


=head1 NAME

Mite::Compiler - Compile Mite accessors and roles

=head1 DESCRIPTION

Compiles the accessors and roles used by Mite classes into stock Perl
files.

=head2 Methods

=head3 inject_mite_functions

    Mite::Compiler->inject_mite_functions(
        package    => $caller,
        mite_file  => $mite_file,
    );

This will inject the L<Mite> functions like C<has>, C<extends>,
etc... into the $caller's package.

When called, they will place compiled code into the $mite_file as well
as load it into the running process.

In this way a module using Mite can compile itself and run in one step.

=cut

sub inject_mite_functions {
    my $class = shift;
    my %args = @_;

    my $package   = $args{package};
    my $mite_file = $args{mite_file};

    # Kill the file dead on VMS
    1 while unlink $mite_file;

    # Eventually, has() will want to rewrite new() to inline
    # argument checks and defaults.  That or it happens
    # as part of "no Mite::Shim" and that's required.
    require Mite::Compiler::new;
    Mite::Compiler::new->new(
        package     => $package,
        mite_file   => $mite_file
    )->compile;

    no strict 'refs';

    *{ $package .'::has' } = sub {
        my $name = shift;

        require Mite::Compiler::has;
        Mite::Compiler::has->new(
            package     => $package,
            mite_file   => $mite_file,
            args        => { name => $name, @_ }
        )->compile;
    };

    *{ $package .'::class_has' } = sub {
        require Mite::Compiler::class_has;
        Mite::Compiler::class_has->new(
            package     => $package,
            mite_file   => $mite_file,
            args        => { @_ }
        )->compile;
    };

    *{ $package .'::extends' } = sub {
        require Mite::Compiler::extends;
        Mite::Compiler::extends->new(
            package     => $package,
            mite_file   => $mite_file,
            args        => [ @_ ]
        )->compile;
    };
}

1;
