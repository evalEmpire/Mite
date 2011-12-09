package Mite::Compiler::new;

use strict;
use warnings;

use parent qw(Mite::Compiler::Base);

sub compile {
    my $self = shift;

    my $code = <<'END';
sub new {
    my $class = shift;
    return bless { @_ }, $class;
}

END

    $self->save_code(\$code);

    return;
}

1;

