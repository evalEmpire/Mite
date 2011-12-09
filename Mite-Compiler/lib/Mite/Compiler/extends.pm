package Mite::Compiler::extends;

use strict;
use warnings;

use parent qw(Mite::Compiler::Base);

sub compile {
    my $self = shift;

    my $parents = $self->args;

    my $require_list = join "\n\t", map { "require $_;" } @$parents;
    my $isa_list     = join ", ", map { "q[$_]" } @$parents;

    my $code = <<"END";
BEGIN {
    $require_list

    our \@ISA;
    push \@ISA, $isa_list;
}

END

    $self->save_code(\$code);

    return;
}

1;
