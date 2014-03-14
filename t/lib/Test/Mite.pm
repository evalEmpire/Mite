package Test::Mite;

use v5.10;
use strict;
use warnings;

use autodie;
use Path::Tiny;
use Method::Signatures;

use Test::Builder::Module;

our @EXPORT = qw(mite_compile mite_load);

func class2pm(Str $class) {
    my $pm = $class.'.pm';
    $pm =~ s{::}{/};

    return $pm;
}

func mite_compile(Str $code, Str :$class, :$dir=tempdir()) {
    # Write the code to a temp file
    my $pmfile = $dir->child( class2pm($class) );
    $pmfile->spew($code);

    # Compile the code
    {
        # Do it in its own process to avoid polluting the test process
        # with compiler code.  This better emulates how it works in production.
        local $ENV{MITE_COMPILE} = 1;
        system("$^X $pmfile");
    }

    return $pmfile;
}

func mite_load(Str $code) {
    my $file = mite_compile($code);

    # Allow the same file to be recompiled and reloaded
    return do $file;
}

1;
