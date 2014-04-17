package Mite::Shim;

# NOTE: Since the intention is to ship this file with a project, this file
# cannot have any non-core dependencies.

use strict;
use warnings;

use version 0.77; our $VERSION = qv("v0.0.1");

sub _is_compiling {
    return $ENV{MITE_COMPILE} ? 1 : 0;
}

sub import {
    my $class = shift;
    my($caller, $file) = caller;

    # Turn on warnings and strict in the caller
    warnings->import;
    strict->import;

    if( _is_compiling() ) {
        require Mite::Project;
        Mite::Project->default->inject_mite_functions(
            package     => $caller,
            file        => $file,
        );
    }
    else {
        # Work around Test::Compile's tendency to 'use' modules.
        # Mite.pm won't stand for that.
        return if $ENV{TEST_COMPILE};

        # Changes to this filename must be coordinated with Mite::Compiled
        my $mite_file = $file . ".mite.pm";
        if( !-e $mite_file ) {
            require Carp;
            Carp::croak("Compiled Mite file ($mite_file) for $file is missing");
        }

        {
            local @INC = ('.', @INC);
            require $mite_file;
        }

        no strict 'refs';
        *{ $caller .'::has' } = sub {
            my $name = shift;
            my %args = @_;

            my $default = $args{default};
            return unless ref $default eq 'CODE';

            ${$caller .'::__'.$name.'_DEFAULT__'} = $default;

            return;
        };

        # Inject blank Mite routines
        for my $name (qw( extends )) {
            no strict 'refs';
            *{ $caller .'::'. $name } = sub {};
        }
    }
}


=head1 NAME

Mite::Shim - Moose-like OO with no dependencies

=head1 SYNOPSIS

    $ mite init Foo

    $ cat lib/Foo.pm
    package Foo;

    # Load the Mite shim
    use Foo::Mite;

    # Subclass of Bar
    extends "Bar";

    # A read/write string attribute
    has "attribute";

    # A read-only attribute with a default
    has another_attribute =>
        is      => 'ro',
        default => 1;

    $ mite compile

=head1 DESCRIPTION

L<Moose> and L<Mouse> are great... unless you can't have any dependencies or
compile-time is critical.

Mite provides Moose-like functionality, but it does all the work at
build time.  New source code is written which contains your accessors
and roles.

Mite is B<not> compatible with Moose, but it tries to stick as close
as possible.

Mite is for a very narrow set of use cases.  Unless you specifically
need ultra-fast startup time or no dependencies, use L<Moose> or
L<Mouse>.

=head2 How To Use It

=head3 1. Install Mite

Only developers must have Mite installed.  Install it normally from
CPAN.

=head3 2. mite init <project-name>

Initialize your project.  Tell it your project name.

=head3 3. Write your code using your mite shim.

Instead of C<use Mite>, you should C<use Your::Project::Mite>.  The
name of this file will depend on the name of your project.

=head3 4. C<mite compile> after each change

Mite is "compiled" in that the code must be processed after editing
before you run it.  This is done by running C<mite compile>.

=head3 5. Make sure the mite files are in your MANIFEST

The compiled F<.mite.pm> files must ship with your code, so make sure
they get picked up in your MANIFEST file.  This should happen by
default.

=head3 6. Ship normally

Build and ship your distribution normally.  It contains everything it
needs.


=head1 WHY IS THIS

This module exists for a very "special" set of use cases.  Authors of
toolchain modules (Test::More, ExtUtils::MakeMaker, File::Spec,
etc...) who cannot easily depend on other CPAN modules.  It would
cause a circular dependency and add instability to CPAN.  These
authors are frustrated at not being able to use most of the advances
in Perl present on CPAN, such as Moose.

To add to their burden, by being used by almost everyone, toolchain
modules limit how fast modules can load.  So they have to compile very
fast.  They do not have the luxury of creating attributes and
including roles at compile time.  It must be baked in.

Finally, Moose and Mouse both require role users and subclassers to
also be Moose or Mouse classes.  This is a dangerous encapsulation
breach of an implementation detail.  It means the class, and its
subclasses, are stuck using Moose or Mouse forever.


=head1 SEE ALSO

L<Mouse> is a forward-compatible version of Moose with no dependencies.

L<Moose> is the complete Perl 5 OO module which this is all based on.

=cut


1;
