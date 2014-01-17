use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::CatalystStarter::Bloated',
    license             => 'artistic2',
    dist_author         => 'Torbjørn Lindahl <torbjorn.lindahl@gmail.com>',
    dist_version_from   => 'lib/App/CatalystStarter/Bloated.pm',
    requires => {
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
    add_to_cleanup      => [ 'App-CatalystStarter-Bloated-*' ],
);

$builder->create_build_script();
