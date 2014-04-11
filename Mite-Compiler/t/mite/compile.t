#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Path::Tiny;

tests "compile" => sub {
    my $Orig_Cwd = Path::Tiny->cwd;
    my $dir = Path::Tiny->tempdir;
    chdir $dir;

    mite_command( init => "Foo" );
    path("lib/Foo")->mkpath;

    path("lib/Foo.pm")->spew(<<'CODE');
package Foo;
use Mite;

has "foo";
has "bar";

1;
CODE

    path("lib/Foo/Bar.pm")->spew(<<'CODE');
package Foo::Bar;
use Mite;
extends 'Foo';

has "baz" =>
    default => sub { 42 };

1;
CODE

    mite_command("compile");

    local @INC = ("lib", @INC);
    require_ok 'Foo';
    require_ok 'Foo::Bar';

    my $foo  = new_ok "Foo", [foo => 99];
    my $fbar = new_ok "Foo::Bar";

    is $foo->foo, 99;
    is $foo->bar, undef;

    is $fbar->foo, undef;
    is $fbar->bar, undef;
    is $fbar->baz, 42;

    chdir $Orig_Cwd;
};

done_testing;
