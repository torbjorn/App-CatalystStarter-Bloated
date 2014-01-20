#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok "App::CatalystStarter::Bloated";

use lib 't/lib';
use TestUtils;

## parse .pgpass
{

    local $ENV{HOME} = "t/lib";

    cmp_deeply(
        [App::CatalystStarter::Bloated::_parse_pgpass()],
        [
            {
                server => "localhost",
                port => 5432,
                database => "thedb",
                user => "user",
                pass => "pass",
            },
            {
                server => "someserver",
                port => 5433,
                database => "otherdb",
                user => "user2",
                pass => "pass2",
            },
        ],
        ".pgpass parsed"
    );

}

done_testing;
