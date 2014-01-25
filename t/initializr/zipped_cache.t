#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use Test::File::ShareDir
    -share => {
        -module => { "App::CatalystStarter::Bloated::Initializr" => 'share' },
    };

use_ok "App::CatalystStarter::Bloated::Initializr";

note( "zip setup tests" );

is( App::CatalystStarter::Bloated::Initializr::_az(), undef, "az undef before init" );

throws_ok { App::CatalystStarter::Bloated::Initializr::_require_az() }
    qr/^\Qaz object not initialized/, "az check dies as expected before init";

isa_ok(
    App::CatalystStarter::Bloated::Initializr::_set_az_from_cache(),
    "Archive::Zip"
);

isa_ok( App::CatalystStarter::Bloated::Initializr::_az(), "Archive::Zip",
        "az after init" );

lives_ok { App::CatalystStarter::Bloated::Initializr::_require_az() }
    "az check lives after init";

note( "zip accessor tests" );

throws_ok { App::CatalystStarter::Bloated::Initializr::_safely_search_one_member("foo") }
    qr/^\QFound more than one zip member match for/,
    "safe search dies on > 1 matches";

done_testing;
