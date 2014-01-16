use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::CatalystStarter::Bloated',
    license             => 'artistic2',
    dist_author         => 'Torbjørn Lindahl <torbjorn.lindahl@gmail.com>',
    dist_version_from   => 'lib/App/CatalystStarter/Bloated.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'App-CatalystStarter-Bloated-*' ],
);

$builder->create_build_script();
