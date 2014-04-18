package Mite::ModuleBuild;

use strict;
use warnings;
use feature ':5.10';
use Method::Signatures;

use parent 'Module::Build';

method ACTION_code() {
    system "mite", "compile";

    return $self->SUPER::ACTION_code;
}

method ACTION_clean() {
    system "mite", "clean";

    return $self->SUPER::ACTION_clean;
}


=head1 NAME

Mite::ModuleBuild - Use in your Build.PL when developing with Mite

=head1 SYNOPSIS

    # In Build.PL
    use Module::Build;
    my $class = eval { require Mite::ModuleBuild } || 'Module::Build';

    my $build = $class->new(
        ...as normal...
    );
    $build->create_build_script;

=head1 DESCRIPTION

If your module is being developed with L<Module::Build>, this
module makes working with L<Mite> more natural.

Be sure to C<require> this in an C<eval> block so users can install
your module without mite.

=head3 C<./Build>

When C<./Build> is run, mite will compile any changes.

=head3 C<./Build clean>

When C<./Build clean> is run, mite files will be cleaned up as well.

=cut

# This allows users to write
# my $class = eval { require Mite::ModuleBuild } || 'Module::Build';
return __PACKAGE__;
