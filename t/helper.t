#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok( "App::CatalystStarter::Bloated" );

App::CatalystStarter::Bloated::_change_cat_dir( "t/lib/testapp" );

is( App::CatalystStarter::Bloated::_helper(),
    "script/testapp_create.pl", "helper found" );

done_testing;
