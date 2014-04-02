#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "all_attributes" => sub {
    my $gparent = sim_class( name => "GP1" );
    my $parent  = sim_class( name => "P1" );
    my $child   = sim_class( name => "C1" );

    $parent->extends(["GP1"]);
    $child->extends(["P1"]);

    $gparent->add_attributes(
        sim_attribute( name => "from_gp" ),
        sim_attribute( name => "this" ),
    );
    $parent->add_attributes(
        sim_attribute( name => "from_p" ),
        sim_attribute( name => "in_p" ),
        sim_attribute( name => "that" )
    );
    $child->add_attributes(
        sim_attribute( name => "in_p" ),
        sim_attribute( name => "from_c" ),
    );

    my $gp_all_attrs_have = $gparent->all_attributes;
    cmp_deeply $gp_all_attrs_have, $gparent->attributes;

    my $p_all_attrs_have  = $parent->all_attributes;
    my %p_all_attrs_want = (
        from_gp         => $gparent->attributes->{from_gp},
        this            => $gparent->attributes->{this},
        from_p          => $parent->attributes->{from_p},
        in_p            => $parent->attributes->{in_p},
        that            => $parent->attributes->{that},
    );
    cmp_deeply $p_all_attrs_have, \%p_all_attrs_want;

    my $c_all_attrs_have  = $child->all_attributes;
    my %c_all_attrs_want = (
        from_gp         => $gparent->attributes->{from_gp},
        this            => $gparent->attributes->{this},
        from_p          => $parent->attributes->{from_p},
        in_p            => $child->attributes->{in_p},
        that            => $parent->attributes->{that},
        from_c          => $child->attributes->{from_c},
    );
    cmp_deeply $c_all_attrs_have, \%c_all_attrs_want;
};

done_testing;
