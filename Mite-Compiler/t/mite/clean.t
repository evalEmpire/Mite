#!/usr/bin/perl

# This is just for testing that "mite clean" basically works.
# Put more elaborate tests into the appropriate class test.

use lib 't/lib';
use Test::Mite;

use Mite::Project;

tests "find_pms and mites" => sub {
    my $orig_dir = Path::Tiny->cwd;
    my $dir = Path::Tiny->tempdir;

    chdir $dir;

    $dir->child("lib", "Foo")->mkpath;
    $dir->child("lib", "Foo.pm")->touch;
    $dir->child("lib", "Foo", "Bar.pm")->touch;

    mite_command "init", "Foo";

    $dir->child("lib", "Foo.pm.mite.pm")->touch;
    $dir->child("lib", "Foo", "Bar.pm.mite.pm")->touch;

    my $project = Mite::Project->default;

    cmp_deeply
      [ sort map { $_.'' } $project->find_mites ],
      [ sort 
          "lib/Foo.pm.mite.pm",
          "lib/Foo/Bar.pm.mite.pm",
      ];

    mite_command "clean";

    cmp_deeply
      [ sort map { $_.'' } $project->find_pms ],
      [ sort
          "lib/Foo.pm",
          "lib/Foo/Bar.pm"
      ], "clean ignores non mite files";

    cmp_deeply
      [ sort map { $_.'' } $project->find_mites ],
      [], "clean only .mite.pm";

    chdir $orig_dir;
};

done_testing;
