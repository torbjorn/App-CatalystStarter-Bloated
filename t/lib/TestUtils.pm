package TestUtils;

use strict;
use warnings;

use Path::Tiny;

sub clean_cat_dir {
    $_->remove_tree for path("t/lib/testdir")->children;
}
