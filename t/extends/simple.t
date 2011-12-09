#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

note "making the test classes"; {
    {
        package GrandParent;
        # Trick Perl into thinking this is a real class
        BEGIN { $INC{"GrandParent.pm"} = __FILE__; }

        sub foo { "gp" }
        sub bar { "gp" }
    }

    {
        package Parent;
        BEGIN { $INC{"Parent.pm"} = __FILE__; }

        use Mite::Shim;
        extends 'GrandParent';

        sub foo { "parent" }

        # Sometimes delete the compile code, to test the compiled code.
        END { Mite::Shim::clear_code if int rand 2; }
    }

    {
        package Child;
        use Mite::Shim;
        extends 'Parent';

        # Sometimes delete the compile code, to test the compiled code.
        END { Mite::Shim::clear_code if int rand 2; }
    }
}


note "extends"; {
    my $child = Child->new;

    isa_ok $child, "Child";
    isa_ok $child, "Parent";
    isa_ok $child, "GrandParent";

    is $child->foo, "parent";
    is $child->bar, "gp";
}


done_testing;
