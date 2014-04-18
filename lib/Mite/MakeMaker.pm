package Mite::MakeMaker;

use strict;
use warnings;
use feature ':5.10';

{
    package MY;

    sub top_targets {
        my $self = shift;
        my $make = $self->SUPER::top_targets;

        # Hacky way to run the mite target before pm_to_blib.
        $make =~ s{(pure_all \s* ::? .*) (pm_to_blib)}{$1 mite $2}x;

        return $make;
    }

    sub postamble {
        return <<'MAKE';
mite ::
	mite compile

clean ::
	mite clean

MAKE
    }
}


=head1 NAME

Mite::MakeMaker - Use in your Makefile.PL when developing with Mite

=head1 SYNOPSIS

    # In Makefile.PL
    use ExtUtils::MakeMaker;
    eval { require Mite::MakeMaker; };

    WriteMakefile(
        ...as normal...
    );

=head1 DESCRIPTION

If your module is being developed with L<ExtUtils::MakeMaker>, this
module makes working with L<Mite> more natural.

Be sure to C<require> this in an C<eval> block so users can install
your module without mite.

=head3 C<make>

When C<make> is run, mite will compile any changes.

=head3 C<make clean>

When C<make clean> is run, mite files will be cleaned up as well.

=cut

1;
