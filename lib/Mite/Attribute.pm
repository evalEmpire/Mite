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
    my $perl_method = $self->is eq 'rw' ? '_compile_rw_perl' : '_compile_ro_perl';
    my $xs_method   = $self->is eq 'rw' ? '_compile_rw_xs'   : '_compile_ro_xs';

    return sprintf <<'CODE', $self->$xs_method, $self->$perl_method;
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

method _compile_ro_xs() {
    my $name = $self->name;

    return <<"CODE";
Class::XSAccessor->import(
    getters => { q[$name] => q[$name] }
);
CODE
}

method _compile_ro_perl() {
    my $name = $self->name;
    return sprintf <<'CODE', $name, $name, $name;
*%s = sub {
    # This is hand optimized.  Yes, even adding
    # return will slow it down.
    @_ > 1 ? require Carp && Carp::croak("%s is a read-only attribute of @{[ref $_[0]]}")
           : $_[0]->{ q[%s] };
};
CODE
}

1;
