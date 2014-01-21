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

use_ok "App::CatalystStarter::Bloated", ":test";

local %ARGV = test_argv;

chdir test_dir;

clean_cat_dir;

App::CatalystStarter::Bloated::_mk_app();

is( App::CatalystStarter::Bloated::_creater(),
    path( cat_name , "script", cat_name(1)."_create.pl" ),
    "create script found" );

clean_cat_dir;

done_testing;
