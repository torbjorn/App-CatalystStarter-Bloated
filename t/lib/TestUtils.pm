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

my $cat_name;

my $test_dir;

sub proj_dir {
    return $proj_dir;
}

sub test_dir {

    if ( not defined $test_dir ) {

        $test_dir = Path::Tiny->tempdir();

    }

    # return path( proj_dir, "t/lib/testdir", @_ );
    return path( $test_dir, @_ );

}

sub cat_name {
    $cat_name //= "TestCat" . join "",
        map { int 10 * rand() + 1 } 1..10;

    my $n = $_[0] ? lc $cat_name : $cat_name;

    return $n;
}

sub test_argv {
    my %argv = ("--name" => cat_name(), @_);

    my %additional;

    while ( my($k,$v) = each %argv ) {
        if ( $k =~ /^--/ ) {
            my $k2 = substr $k, 1;
            $additional{$k2} = $argv{$k};
        }
    }

    %argv = (%argv,%additional);

    return %argv;
}

sub goto_test_dir {
    chdir path( test_dir );
}

sub clean_cat_dir {
    $_->remove_tree for test_dir->children;
}

END {
    chdir proj_dir;
}

1;
