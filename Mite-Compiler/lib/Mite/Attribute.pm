package Mite::Attribute;

use Mouse;
use Method::Signatures;

has default =>
  is            => 'rw',
  isa           => 'Maybe[Str|Ref]',
  predicate     => 'has_default';

has coderef_default_variable =>
  is            => 'rw',
  isa           => 'Str',
  lazy          => 1,           # else $self->name might not be set
  default       => method {
      return sprintf '$__%s_DEFAULT__', $self->name;
  };

has is =>
  is            => 'rw',
  isa           => 'Str',
  default       => 'rw';

has name =>
  is            => 'rw',
  isa           => 'Str',
  required      => 1;

method has_dataref_default() {
    # We don't have a default
    return 0 unless $self->has_default;

    # It's not a reference.
    return 0 if $self->has_simple_default;

    return ref $self->default ne 'CODE';
}

method has_coderef_default() {
    # We don't have a default
    return 0 unless $self->has_default;

    return ref $self->default eq 'CODE';
}

method has_simple_default() {
    return 0 unless $self->has_default;

    # Special case for regular expressions, they do not need to be dumped.
    return 1 if ref $self->default eq 'Regexp';

    return !ref $self->default;
}

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
