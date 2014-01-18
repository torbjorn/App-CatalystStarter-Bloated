#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok "App::CatalystStarter::Bloated";

## _prepare_dsn

## makes it o so more convenient
local *prepare_dsn = *App::CatalystStarter::Bloated::_prepare_dsn;

is( prepare_dsn( "Pg" ), "dbi:Pg:", "bare driver name" );
is( prepare_dsn( "dbi:Pg" ), "dbi:Pg:", "lacking 2nd :" );
is( prepare_dsn( "dBi:Pg" ), "dbi:Pg:", "bad case in dbi" );
is( prepare_dsn( "Pg:dbname=foo" ), "dbi:Pg:dbname=foo", "missing leading dbi:" );
is( prepare_dsn( ":Pg" ), "dbi:Pg:", "missing leading dbi" );

## _parse_dbi_dsn

local *parse_dbi_dsn = *App::CatalystStarter::Bloated::_parse_dbi_dsn;

cmp_deeply(
    parse_dbi_dsn("database=foo;host=bar;port=1234"),
    { database => "foo", host => "bar", port => 1234 },
    "plain values for db, host and port"
);

cmp_deeply(
    parse_dbi_dsn("dbname=foo;host=bar;port=2345"),
    { database => "foo", host => "bar", port => 2345 },
    "database variation 1: dbname"
);

cmp_deeply(
    parse_dbi_dsn("db=foo;host=bar;port=3456"),
    { database => "foo", host => "bar", port => 3456 },
    "database variation 2: db"
);

cmp_deeply(
    parse_dbi_dsn(""),
    { database => undef, host => undef, port => undef },
    "empty string dsn"
);

cmp_deeply(
    parse_dbi_dsn("db=foo;host=bar;port=3456;foo=bar;baz=test"),
    { database => "foo", host => "bar", port => 3456, foo => "bar", baz => "test" },
    "unknown parameters included"
);

is(
    parse_dbi_dsn(),
    undef,
    "missing dsn"
);

done_testing;
