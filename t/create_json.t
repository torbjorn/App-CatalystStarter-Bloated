#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Test::Output;

use lib 't/lib';
use TestUtils;

use_ok "App::CatalystStarter::Bloated", ":test";

clean_cat_dir;

goto_test_dir;

local %ARGV = test_argv( "--JSON" => "JSON2" );

App::CatalystStarter::Bloated::_mk_app();
App::CatalystStarter::Bloated::_create_JSON();

ok( -e App::CatalystStarter::Bloated::_catalyst_path( "V", "JSON2.pm" ),
    "create JSON view" );

clean_cat_dir;

App::CatalystStarter::Bloated::_mk_app();
$ARGV{"--verbose"} = 1;
stdout_like sub { App::CatalystStarter::Bloated::_create_JSON() },
    qr/\bcreated.*JSON2\.pm\b/,
    "verbose create";

clean_cat_dir;

done_testing;
