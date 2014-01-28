use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::CatalystStarter::Bloated',
    license             => 'artistic',
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
        'Archive::Zip'        => '1.30',
        'Capture::Tiny'       => '0.23',
        'DBI'                 => '1.63',
        'File::ShareDir'      => '1.03',
        'HTML::TreeBuilder'   => '5.03',
        'List::MoreUtils'     => '0.33',
        'Log::Log4perl'       => '1.42',
        'Sys::SigAction'      => '0.21',
        'Test::Output'        => '1.02',
        'Test::File::ShareDir' => '0.3.1',
        'Module::Build'       => '0.42',
        'Catalyst::Runtime'   => 0,
    },
    add_to_cleanup      => [ 'App-CatalystStarter-Bloated-*' ],
);

$builder->create_build_script();
