package Mite;

use strict;
use warnings;

use version 0.77; our $VERSION = qv("v0.0.1");


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
    has "another_attribute" => {
        is      => 'ro',
        type    => 'Int',
        default => 1
    };


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

Only developers must have Mite installed.  Install it normally from CPAN.

=head3 2. Inject the Mite::Shim into your source code

Mite must have a small module bundled with your code.  This loads the
Mite compiled code and provides dummy versions of all the exported
functions.  It allows your code to run without needing to modify the
source code.

Run the C<mite_shim> program to generate the shim.  Tell it the name
you want to give to the shim.  Put it into your lib directory.

    mite_shim("Foo::Mite") > lib/Foo/Mite.pm

=head3 3. Develop normally

Mite will detect when your code has changed and recompile itself.  It
will create F<Foo_mite.pl> files next to any file using Mite.  These
contain the compiled code.

It is not necessary, but it is safe and encouraged to commit these
files to source control.  They will provide a running history of the
real code that is running and help reproduce bugs.

It's safe to delete the mite files, they will be rebuilt next time the
code runs.

=head3 4. Make sure the mite files are in your MANIFEST

The compiled F<Foo_mite.pl> files must ship with your code, so make
sure they get picked up in your MANIFEST file.

=head3 5. Ship normally

Build and ship your distribution normally.  It contains everything it
needs.  Do not add Mite as a dependency.


=head2 Exported Functions

=head3 extends

    extends @classes;

Declares this is a subclass of C<@classes>.


=head3 has

    has $name => \%args;

Declares an object attribute named $name.

See L<Attributes> for details.


=head3 class_has

    class_has $name => \%args;

Declares a class attribute named $name.

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
breech of an implementation detail.  It means the class, and its
subclasses, are stuck using Moose or Mouse forever.


=head1 SEE ALSO

L<Mite::Object> is what all Mite classes inherit from.

L<Mite::Role> is used to define roles.

L<Mouse> is a forward-compatible version of Moose with no dependencies.

L<Moose> is the complete Perl 5 OO module which this is all based on.

=cut


1;
