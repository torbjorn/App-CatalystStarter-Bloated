#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok( "App::CatalystStarter::Bloated" );

App::CatalystStarter::Bloated::_finalize_argv();

cmp_deeply( [@ARGV{qw/-html5 --html5 -h5 --h5/}], [1,1,1,1], "default flags are on" );

done_testing;
