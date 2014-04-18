package Some::Project;

our $VERSION = 1.23;
use Some::Project::Mite;

has something =>
  default       => sub { [23, 42] };

1;
