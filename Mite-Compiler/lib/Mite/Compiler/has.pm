package Mite::Compiler::has;

use strict;
use warnings;

use parent qw(Mite::Compiler::Base);

sub compile {
    my $self = shift;

    my $args = $self->args;

    my $code;
    if( $args->{is} eq 'rw' ) {
        $code = $self->_rw;
    }
    else {
        $code = $self->_ro;
    }
    $self->save_code(\$code);

    return;
}


sub _rw {
    my $self = shift;
    my $name = $self->args->{name};

    return sprintf <<'END', $name, $name, $name;
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
}


sub _ro {
    my $self = shift;

    my $name = $self->args->{name};
    return sprintf <<'END', $name, $name, $name;
sub %s {
    my $self = shift;

    if( @_ ) {
        require Carp;
        my $class = ref $self;
        Carp::croak("%s is a read-only attribute of $class");
    }
    else {
        return $self->{ q[%s] };
    }
}
END

}

1;
