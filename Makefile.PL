use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::CatalystStarter::Bloated',
    AUTHOR              => 'Torbjørn Lindahl <torbjorn.lindahl@gmail.com>',
    VERSION_FROM        => 'lib/App/CatalystStarter/Bloated.pm',
    ABSTRACT_FROM       => 'lib/App/CatalystStarter/Bloated.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-CatalystStarter-Bloated-*' },
);
