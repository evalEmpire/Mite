package Mite::App::Command;

use Mouse;
use MouseX::Foreign;
extends qw(App::Cmd::Command);

use Method::Signatures;
use Scalar::Util qw(reftype);

# Work around the bug in MouseX::Foreign (and probably BUILDARGS)
# which fails to recognize a blessed hash ref as valid arguments.
method BUILDARGS($class:...) {
    if( @_ == 1 ) {
        $class->meta->throw_error("Single parameters to new() must be a HASH ref")
          unless reftype($_[0]) eq 'HASH';
        return {%{$_[0]}};
    }
    else {
        return {@_};
    }
}

1;
