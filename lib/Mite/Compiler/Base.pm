package Mite::Compiler::Base;

use strict;
use warnings;

# Do the eval in the caller's package and before any other pragma
# are loaded which might interfere.
# We do want strict and warnings.
sub clean_eval {
    my $self = shift;
    my $code_ref = shift;

    # Isolate globals
    local($!, $?, $@);

    my $package = $self->package;
    my $ok = eval "package $package;\n" . $$code_ref . "; 1";
    die $@ unless $ok;

    return;
}


sub save_code {
    my $self = shift;
    my $code_ref = shift;

    my $fh = $self->mite_fh;

    # Save the code in the mite file
    print $fh $$code_ref;

    # So the file returns a true value
    print $fh ";1;\n";

    # Load it into the current process
    $self->clean_eval($code_ref);

    return;
}


sub new {
    my $class = shift;
    my %args = @_;

    return bless \%args, $class;
}

sub args {
    my $self = shift;

    return $self->{args} || {};
}

sub package {
    my $self = shift;

    return $self->{package};
}

sub mite_file {
    my $self = shift;

    return $self->{mite_file};
}

# This is not multiprocess safe.
sub mite_fh {
    my $self = shift;

    my $mite_file = $self->mite_file;

    # No file exists, make a new one and write the header.
    if( !-e $mite_file ) {
        $self->touch($mite_file);

        my $package = $self->package;

        my $code = <<"END";
package $package;

use strict;
use warnings;

END

        $self->save_code(\$code);
    }

    open my $fh, ">>", $self->mite_file;

    return $fh;
}


sub touch {
    my $self = shift;
    my $file = shift;

    open my $fh, ">>", $file;
    close $fh;
}

1;
