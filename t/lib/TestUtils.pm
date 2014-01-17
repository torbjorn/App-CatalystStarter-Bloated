package TestUtils;

use strict;
use warnings;

use Path::Tiny;

use base 'Exporter';
our @EXPORT = qw/clean_cat_dir
                 test_argv
                 goto_test_dir
                 cat_name
                 proj_dir test_dir/;

my $proj_dir = Path::Tiny->cwd;

sub proj_dir {
    return $proj_dir;
}

sub test_dir {
    return path( proj_dir, "t/lib/testdir", @_ );
}

sub cat_name {
    return "TestCat";
}

sub test_argv {
    my %argv = ("--name" => cat_name(), @_);
    return %argv;
}

sub goto_test_dir {
    chdir path( test_dir );
}

sub clean_cat_dir {
    $_->remove_tree for test_dir->children;
}

END {
    if ( test_dir->children ) {
        warn path($0)->basename, ": I did not clean up testdir after me, I am a bad script\n";
    }
}
