package Mite::Types;

use v5.10;
use Mouse::Util::TypeConstraints;

class_type 'Path::Tiny';

subtype 'Path' =>
  as 'Path::Tiny';

coerce 'Path' =>
  from 'Str',
  via {
      require Path::Tiny;
      return Path::Tiny->new($_);
  };

no Mouse::Util::TypeConstraints;

1;
