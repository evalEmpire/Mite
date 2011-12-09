package Mite::Compiler::has;

use strict;
use warnings;

use parent qw(Mite::Compiler::Base);

sub compile {
    my $self = shift;

    my $args = $self->args;

    my $name = $args->{name};

    my $code = sprintf <<'END', $name, $name, $name;
sub %s {
    my $self = shift;

    if( @_ ) {
        $self->{ q[%s] } = shift;
        return;
    }
    else {
        return $self->{ q[%s] };
    }
}

END

    $self->save_code(\$code);

    return;
}

1;
