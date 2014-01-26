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

## some basic functions for control and setup

note( "zip setup and safely check tests" );

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

## search one

*search_one = *App::CatalystStarter::Bloated::Initializr::_safely_search_one_member;

throws_ok { search_one(qr/./) }
    qr/^\QFound 0 or more than one zip member match for/,
    "safe search dies on > 1 matches";

throws_ok { search_one(qr/THIS SHOULD NOT BE IN ANY OF THE ZIP MEMBERS/) }
    qr/^\QFound 0 or more than one zip member match for/,
    "a non matching qr also dies";

lives_ok { search_one(qr/THIS SHOULD NOT BE IN ANY OF THE ZIP MEMBERS/, 1) }
    "a non matching qr lives when allowed to";

isa_ok( search_one( qr(^initializr/index\.html$) ), "Archive::Zip::Member",
        "index.html" );

## content related

note( "zipped content handling" );

*content = *App::CatalystStarter::Bloated::Initializr::_zip_content;

like( my $c0 = content( qr(/main.css$) ), qr/Author's custom styles/, "content check" );

is( $c0, content( qr(/main.css$)), "content not changed with no 2nd argument" );

lives_ok {content( qr(/main.css$), "/* new css file content /*\n" )}
    "zip member content can beupdated";

is( content( qr(/main.css$)), "/* new css file content /*\n",
    "new content reflected in zip" );

lives_ok {content( qr(/main.css$), $c0 )} "original content can inserted";

is( content( qr(/main.css$)), $c0, "original reflected in zip" );

## accessor related functions

note( "zip member particulars" );

# isa_ok( my $index = App::CatalystStarter::Bloated::Initializr::_index_dom(),
#         "Mojo::DOM" );

## higher level function

note( "HIGH LEVEL FUNCTIONS" );


## setup index
note( "setup index" );

lives_ok {App::CatalystStarter::Bloated::Initializr::_setup_index()}
    "index process complets alive";

## check that index.html doesn't exist
## (should be renamed to wrapper.tt2 by now)
is( search_one( qr/index\.html$/, 1), undef, "index.html not in archive" );

ok( search_one( qr/wrapper\.tt2$/ ), "wrapper.tt2 *is* in archive" );

## sanity checks on wrapper

my $w = content( qr/wrapper\.tt2$/ );

like( $w, qr(<!DOCTYPE html>), "wrapper contains doctype html" );
like( $w, qr([% content %]), "wrapper contains content tt var" );
like( $w, qr([% jumbotron %]), "wrapper contains jumbotron tt var" );

## check that img/ is now images/

App::CatalystStarter::Bloated::Initializr::_process_images();
is( search_one( qr(^/img/), 1 ), undef, "no img/ members found in zip" );

done_testing;
