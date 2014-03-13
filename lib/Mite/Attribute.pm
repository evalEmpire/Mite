package Mite::Attribute;

use Mouse;
use Method::Signatures;

has default =>
  is            => 'rw',
  isa           => 'Maybe[Str|CodeRef]';

has is =>
  is            => 'rw',
  isa           => 'Str',
  default       => 'rw';

has name =>
  is            => 'rw',
  isa           => 'Str',
  required      => 1;

method compile() {
    return $self->is eq 'rw' ? $self->_compile_rw : $self->_compile_ro;
}

method _compile_rw() {
    my $name = $self->name;

    return sprintf <<'CODE', $name, $name, $name;
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
CODE

}

method _compile_ro() {
    my $name = $self->name;
    return sprintf <<'CODE', $name, $name, $name;
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
CODE
}

1;
