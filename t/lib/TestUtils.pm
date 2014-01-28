package TestUtils;

use strict;
use warnings;

use Path::Tiny;
use IO::All;

use base 'Exporter';
our @EXPORT = qw/clean_cat_dir
                 test_argv
                 goto_test_dir
                 cat_name
                 proj_dir test_dir
                 fatstart
                 a_temp_dir
                 go_back
                 temp_sqlite_db
                /;

use Test::File::ShareDir
    -share => {
        -module => { "App::CatalystStarter::Bloated::Initializr" => 'share' },
    };

my $proj_dir = Path::Tiny->cwd;

my $cat_name;

my $test_dir;

sub a_temp_dir {
    return Path::Tiny->tempdir;
}

sub go_back {
    chdir $proj_dir;
}

sub fatstart {
    return path( $proj_dir, "bin", "catalyst-fatstart.pl" )->absolute;
}

sub temp_sqlite_db {

    my($where, $fname) = @_;

    $where //= path(".")->absolute;
    $fname //= "db.sqlite";

    my $sql = <<SQL;
create table foo (
 bar text,
 baz integer,
 id integer primary key );
SQL

    my $p = path( $where, $fname );

    $sql > io->pipe("sqlite3 $p");

    return ($p,"dbi:SQLite:dbname=" . $p);

}

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
