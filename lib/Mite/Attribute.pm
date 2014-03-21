package Mite::Attribute;

use Mouse;
use Method::Signatures;

has default =>
  is            => 'rw',
  isa           => 'Maybe[Str|CodeRef]',
  predicate     => 'has_default';

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
    return sprintf <<'CODE', $self->_compile_rw_xs, $self->_compile_rw_perl;
if( !$ENV{MITE_PURE_PERL} && eval { require Class::Accessor } ) {
%s
}
else {
%s
}
CODE
}

method _compile_rw_xs() {
    my $name = $self->name;

    return <<"CODE";
Class::XSAccessor->import(
    accessors => { q[$name] => q[$name] }
);
CODE

}

method _compile_rw_perl() {
    my $name = $self->name;

    return sprintf <<'CODE', $name, $name, $name;
*%s = sub {
    # This is hand optimized.  Yes, even adding
    # return will slow it down.
    @_ > 1 ? $_[0]->{ q[%s] } = $_[1]
           : $_[0]->{ q[%s] };
}
CODE

}

method _compile_ro() {
    my $name = $self->name;
    return sprintf <<'CODE', $name, $name, $name;
sub %s {
    # This is hand optimized.  Yes, even adding
    # return will slow it down.
    @_ > 1 ? require Carp && Carp::croak("%s is a read-only attribute of @{[ref $_[0]]}")
           : $_[0]->{ q[%s] };
}
CODE
}

1;
