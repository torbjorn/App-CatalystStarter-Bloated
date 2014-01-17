#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Path::Tiny;

use lib 't/lib';
use TestUtils;

clean_cat_dir;

use_ok( "App::CatalystStarter::Bloated" );

local %ARGV = test_argv;

chdir "t/lib/testdir";

clean_cat_dir;

App::CatalystStarter::Bloated::_mk_app();

is( App::CatalystStarter::Bloated::_creater(),
    "TestCat/script/testcat_create.pl",
    "create script found" );

clean_cat_dir;

done_testing;
