#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok "App::CatalystStarter::Bloated";

## makes it o so more convenient
local *prepare_dsn = *App::CatalystStarter::Bloated::_prepare_dsn;

is( prepare_dsn( "Pg" ), "dbi:Pg:", "bare driver name" );
is( prepare_dsn( "dbi:Pg" ), "dbi:Pg:", "lacking 2nd :" );
is( prepare_dsn( "dBi:Pg" ), "dbi:Pg:", "bad case in dbi" );
is( prepare_dsn( "Pg:dbname=foo" ), "dbi:Pg:dbname=foo", "missing leading dbi:" );
is( prepare_dsn( ":Pg" ), "dbi:Pg:", "missing leading dbi" );



done_testing;
