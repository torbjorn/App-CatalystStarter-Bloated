#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Path::Tiny;

use_ok "App::CatalystStarter::Bloated";

use lib 't/lib';
use TestUtils;

local %ARGV = test_argv;

goto_test_dir;

App::CatalystStarter::Bloated::_mk_app();
App::CatalystStarter::Bloated::_create_TT();

is(
    App::CatalystStarter::Bloated::_catalyst_path( "scripts" ),
    path( proj_dir(), "t", "lib", "testdir", cat_name(), "scripts" )->absolute,
    "path to scripts"
);

done_testing;
