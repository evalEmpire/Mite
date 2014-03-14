package Mite::Class;

use v5.10;
use Mouse;
use Mouse::Util::TypeConstraints;
use Method::Signatures;
use Path::Tiny;
use Carp;

class_type "Path::Tiny";

has attributes =>
  is            => 'rw',
  isa           => 'HashRef[Mite::Attribute]',
  default       => sub { {} };

has extends =>
  is            => 'rw',
  isa           => 'ArrayRef',
  default       => sub { [] };

has name =>
  is            => 'rw',
  isa           => 'Str',
  required      => 1;

has file =>
  is            => 'rw',
  isa           => 'Str|Path::Tiny',
  required      => 1;

has mite_file =>
  is            => 'rw',
  isa           => 'Str|Path::Tiny',
  default       => method {
      my $file = $self->file;
      my $mite_file = $file;

      # Ensure it always has a .mite on the end no matter what
      $mite_file =~ s{\.[^\.]*$}{};
      $mite_file .= '.mite';

      croak("The mite file is the same as the file ($file)") if $file eq $mite_file;

      return $mite_file;
  };

method write_mite() {
    my $file = path $self->mite_file;
    $file->spew_utf8( $self->compile );

    return;
}

method delete_mite() {
    my $file = $self->mite_file;

    # Kill the file dead on VMS
    1 while unlink $file;
}

method add_attributes(Mite::Attribute @attributes) {
    for my $attribute (@attributes) {
        $self->attributes->{ $attribute->name } = $attribute;
    }

    return;
}
*add_attribute = \&add_attributes;

method compile() {
    return join "\n", '{',
                      $self->_compile_package,
                      $self->_compile_pragmas,
                      $self->_compile_extends,
                      $self->_compile_new,
                      $self->_compile_attributes,
                      '1;',
                      '}';
}

method _compile_package {
    return "package @{[ $self->name ]};";
}

method _compile_pragmas {
    return <<'CODE';
use strict;
use warnings;
CODE
}

method _compile_extends() {
    my $parents = $self->extends;
    return '' unless @$parents;

    my $require_list = join "\n\t", map { "require $_;" } @$parents;
    my $isa_list     = join ", ", map { "q[$_]" } @$parents;

    return <<"END";
BEGIN {
    $require_list

    our \@ISA;
    push \@ISA, $isa_list;
}
END
}

method _compile_new() {
    return sprintf <<'CODE', $self->_compile_defaults;
sub new {
    my $class = shift;
    my %%args  = @_;

    %s

    return bless \%%args, $class;
}
CODE
}

method _compile_string_default($attribute, :$arg_hash='$args{%s}') {
    return sprintf "$arg_hash //= q[%s];", $attribute->name, $attribute->default;
}

method _compile_defaults {
    return join "\n", map { $self->_compile_string_default($_) }
                          $self->_attributes_with_string_defaults;
}

method _attributes_with_defaults() {
    my @defaults;
    for my $attribute (values %{$self->attributes}) {
        my $default = $attribute->default;
        next unless defined $default;

        my $name = $attribute->name;

        push @defaults, $default;
    }

    return \@defaults;
}

method _attributes_with_string_defaults() {
    return grep { !ref $_->default } @{$self->_attributes_with_defaults};
}

method _attributes_with_code_defaults() {
    return grep { ref $_->default } @{$self->_attributes_with_defaults};
}

method _compile_attributes() {
    my $code = '';
    for my $attribute (values %{$self->attributes}) {
        $code .= $attribute->compile;
    }

    return $code;
}

1;
