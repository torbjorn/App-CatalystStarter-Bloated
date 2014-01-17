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
        'File::Which'         => '1.09',
        'IO::Prompter'        => '0.004010',
        'Path::Tiny'          => '0.051',
        'Test::FailWarnings'  => '0.008',
        'Test::Most'          => '0.31',
        'Test::Perl::Critic'  => '1.02',
        'Test::Pod'           => '1.48',
        'Test::Pod::Coverage' => '1.08',
        'utf8::all'           => '0.011',
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-CatalystStarter-Bloated-*' },
);
