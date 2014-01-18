#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Test::Output;
use Path::Tiny;

use lib 't/lib';
use TestUtils;

use_ok "App::CatalystStarter::Bloated";

my $proj_dir = Path::Tiny->cwd;

clean_cat_dir;

chdir 't/lib/testdir';

stdout_is(
    sub {
        local %ARGV = ("--name" => "MyCatApp");
        App::CatalystStarter::Bloated::_mk_app();
    },
    "",
    "create app without verbose" );

ok( -d test_dir("MyCatApp"), "test app created" );

clean_cat_dir;

stdout_like(
    sub {
        local %ARGV = ( "--name" => "MyCatApp2", "--verbose" => 1 );
        App::CatalystStarter::Bloated::_mk_app();
    },
    qr(CatApp2),
    "create app with verbose" );

ok( -d test_dir("MyCatApp2"), "test app created" );

clean_cat_dir;

done_testing;
