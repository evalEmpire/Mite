package Mite;

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
            name        => $caller,
            file        => $file,
        );
    }
    else {
        # Work around Test::Compile's tendency to 'use' modules.
        # Mite.pm won't stand for that.
        return if $ENV{TEST_COMPILE};

        # This must be coordinated with Mite::Class->mite_file
        my $mite_file = $file . ".mite.pmc";
        if( !-e $mite_file ) {
            require Carp;
            Carp::croak("Compiled Mite file ($mite_file) for $file is missing");
        }

        require $mite_file;

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

Mite - Moose-like OO with no dependencies

=head1 SYNOPSIS

    package Foo;

    # Mite roles do not require anything special to use
    use Foo::Some::Role;

    # Load the Mite shim
    use Foo::Mite;

    # Subclass of Bar
    extends "Bar";

    # A read/write string attribute
    has "attribute";

    # A read-only integer attribute with a default
    has another_attribute => (
        is      => 'ro',
        type    => 'Int',
        default => 1
    );


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

=head3 1. Install Mite::Compiler

Only developers must have Mite::Compiler installed.  Install it
normally from CPAN.

=head3 2a. Depend on Mite

Add Mite into your runtime dependencies.  This is a very small module
which loads the compiled Mite code.

Or if you want no dependencies at all...

=head3 2b. Inject the Mite::Shim into your source code

Run the C<mite_shim> program to generate the shim.  Tell it the name
you want to give to the shim.  Put it into your lib directory.

    mite_shim 'Foo::Mite' > lib/Foo/Mite.pm

=head3 3. Run C<mite> when you change your code.

Mite is "compiled" in that the code must be processed after editing
before you run it.  This is done with the C<mite> program.

=head3 4. Make sure the mite files are in your MANIFEST

The compiled F<Foo.mite> files must ship with your code, so make
sure they get picked up in your MANIFEST file.

=head3 5. Ship normally

Build and ship your distribution normally.  It contains everything it
needs.


=head2 Exported Functions

=head3 extends

    extends @classes;

Declares this is a subclass of C<@classes>.


=head3 has

    has $name => %args;

Declares an object attribute named $name.

See L<Attributes> for details.


=head2 Provided Methods

See L<Mite::Object> for full details of what a Mite class can do.
Here are some of the basics.

=head3 meta

    my $meta = $obj->meta;
    my $meta = Class->meta;

Returns the meta object for the class.  Used for introspection.

See L<Mite::Meta> for what you can do with the meta object.

=head3 new

    my $obj = Class->new( \%args );

Constructs a new instance of the C<Class>.

Arguments are passed in as a hash ref.

C<new()> accepts attributes as its arguments.

    my $obj = Foo->new(
        attribute               => "Foo",
        another_attribute       => 42
    ); 

=head3 override_attribute

    Class->meta->override_attribute( name => \%args );

Allows a subclass to change how an inherited attribute works.

The C<%args> are the same as L<has>.

    # Baz is a subclass of Foo
    # Give Baz->attribute a default
    Baz->override_attribute( attribute => {
        default         => 'woof'
    });


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

L<Mite::Compiler> is what you need to develop with Mite.

L<Mouse> is a forward-compatible version of Moose with no dependencies.

L<Moose> is the complete Perl 5 OO module which this is all based on.

=cut


1;
