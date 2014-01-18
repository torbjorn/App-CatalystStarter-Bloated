#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
# use Test::FailWarnings;

use lib 't/lib';
use TestUtils;

use_ok( "App::CatalystStarter::Bloated" );

## check that html5 gets initalized with right defaults
{
    local %ARGV = test_argv;

    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-html5 --html5 -h5 --h5/}],
                [1,1,1,1], "default flags are on" );

}

## check default model name convention
{
    local %ARGV = test_argv( "--model" => "AppNameDB" );

    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-model --model/}],
                [qw/TestCatDB/x2], "model name convention" );

}

## check that explicit model names are preserved
{
    local %ARGV = test_argv( "--model" => "FooDB" );

    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-model --model/}], [qw/FooDB/x2],
                "model name not changed when set" );

}

## check that model value 1 is treated correctly
{
    local %ARGV = test_argv( "--model" => 1 );

    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-model --model/}], [qw/TestCatDB/x2],
                "model name fixed when value is 1" );

}

## check that --views are sets up both views
{
    local %ARGV = test_argv( "--views" => 1 );

    ## check that --views trigger both TT and JSON
    delete @ARGV{qw/--TT --JSON/};
    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-TT --TT -JSON --JSON/}],
                [qw/HTML HTML JSON JSON/], "TT and JSON when --views");

}

## check that --views doesnt touch existnig --tt or --json
{
    local %ARGV = test_argv( "--views" => 1, "--TT" => "MyView", "-TT" => "MyView" );

    ## check that --views trigger both TT and JSON
    delete @ARGV{qw/--JSON/};
    App::CatalystStarter::Bloated::_finalize_argv();

    cmp_deeply( [@ARGV{qw/-TT --TT -JSON --JSON/}],
                [qw/MyView MyView JSON JSON/], "TT and JSON when --views");

}



done_testing;
