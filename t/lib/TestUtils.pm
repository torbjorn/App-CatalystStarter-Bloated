package TestUtils;

use strict;
use warnings;

use Path::Tiny;

use base 'Exporter';
our @EXPORT = qw/clean_cat_dir test_argv goto_test_dir cat_name proj_dir/;

my $proj_dir = Path::Tiny->cwd;

sub proj_dir {
    return $proj_dir;
}

sub cat_name {
    return "TestCat";
}

sub test_argv {
    my %argv = ("--name" => cat_name(), @_);
    return %argv;
}

sub goto_test_dir {
    chdir path( $proj_dir, "t/lib/testdir");
}

sub clean_cat_dir {
    $_->remove_tree for path( $proj_dir, "t/lib/testdir")->children;
}
