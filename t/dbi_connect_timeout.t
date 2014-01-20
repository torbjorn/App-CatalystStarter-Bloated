#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use Sys::SigAction qw/timeout_call/;
use Time::HiRes qw/gettimeofday tv_interval usleep/;
use DBI;

my $sqlite_file = "t/lib/testdir/foo.sqlite";

my $dsn = sprintf "dbi:SQLite:dbname=%s", $sqlite_file;

my $sub = sub {
    DBI->connect( $dsn );
};

## measure 3 times and take the median
my @measured;
for ( 1..3 ) {

    my $t0 = [gettimeofday];
    $sub->();
    my $t1 = [gettimeofday];

    push @measured, tv_interval($t0,$t1);

}

my $duration = (sort(@measured))[1];

pass( "test run succeeded" );

note( "Test run took: $duration seconds" );

ok( !timeout_call(  $duration * 1e3, $sub),
    "timeout #1 should not timeout with a long timeout" );

ok( timeout_call(  1e-6, sub { $sub->() } ),
    "timeout #2 should timeout with 1µs timeout"
);

unlink $sqlite_file;

done_testing;
