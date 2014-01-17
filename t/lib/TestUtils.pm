package TestUtils;

use strict;
use warnings;

use Path::Tiny;

use base 'Exporter';
our @EXPORT = qw/clean_cat_dir/;

my $proj_dir = Path::Tiny->cwd;

sub clean_cat_dir {
    $_->remove_tree for path( $proj_dir, "t/lib/testdir")->children;
}
