package Mite::App;

use feature ':5.10';
use strict;
use warnings;

# Need to ensure that inlined type constraints
# don't attempt to use Type::Tiny::XS
BEGIN {
    $ENV{PERL_TYPE_TINY_XS} = 0;
    
    my $using_xs;
    eval {
        require Type::Tiny;
        $using_xs = Type::Tiny::_USE_XS();
    };
    
    die "Please disable Type::Tiny::XS and try again!"
        if $using_xs;
};

use App::Cmd::Setup -app;

1;
