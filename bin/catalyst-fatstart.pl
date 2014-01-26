#!/usr/bin/perl

use v5.10.1;

use utf8::all;
use strict;
use autodie;
use warnings;
use Carp qw< carp croak confess cluck >;

use Getopt::Euclid;

use Test::File::ShareDir
    -share => {
        -module => { "App::CatalystStarter::Bloated::Initializr" => 'share' },
    };

use App::CatalystStarter::Bloated;
App::CatalystStarter::Bloated::run;

__END__

=encoding utf8

=head1 NAME

catalyst-fatstart.pl - catalyst starter that tries to know better than
you

=head1 VERSION

This app and its module is currently at a puny version 0.0.1

=head1 SYNOPSIS

# just like catalyst.pl MyCatApp
catalyst-fatstart.pl -n MyCatApp

# the same, but adds a


=head1 DESCRIPTION

This script starts a new catalyst project. It uses catalyst.pl that
comes with Catalyst::Runtime to do the dirty work.

Furthermore it optionally does zero or more of the following:

=over

=item Adds a TT view, see --TT. Also see --views which is short for
doing both TT and JSON.

=item Adds a JSON view, see --JSON

=item Adds a model with a schema. If not spesified, they get default
names. Note:

=over

=item Only ever does DBIC::Schema models. Do not use this is you use
other types of models.

=item Always uses create=static to create schema files. Do not create
a model with this tool if you don't mean to create schema files.

=back

=item Adds a HTML5 template. Currently from initializr.com with a reasonable selection including jquery and bootstrap.

=back

=head1 USAGE

    catalyst-fatstart.pl [options] -n[ame]=name-of-catalyst-app

=head1 REQUIRED ARGUMENTS

=over

=item -[-]n[ame] [=] <name>

Name of catalyst app, what you would otherwise specify like this:
catalyst.pl name

=for Euclid:
    name.type: str

=back

=head1 OPTIONS

=over

=item -[-]TT [=] [<HTML>]

Add a Catalyst::View::TT view, defaults to YourApp::View::HTML.

In addition to defaults created with Catalyst::Helper it will also be
configured with:

    TEMPLATE_EXTENSION => 'tt2',
    WRAPPER => 'wrapper.tt2',

The ::HTML part of the package name can be changed by giving the
argument a value, ie --TT MyView would create YourApp::View::MyView
instead.

The 'YourApp::View::' part of the package name is automatic and
unchangable here.

Also touches root/index.tt2 and root/wrapper.tt2. If wrapper.tt2 is
empty it inserts [% content %] in it.

=for Euclid:
    HTML.opt_default = "HTML"

=item -[-]JSON [=] [<JSON>]

Add a Catalyst::View::JSON view, defaults to YourApp::View::JSON. The
same rules and options applies as to --TT

In addition to any defaults set by Catalyst::Helper, it also
configures:

    export_stash => [ qw(json) ],

This means that only data in $c->stash->{json} will be included in
output. Remove this config line afterwards if you do not want it.

=for Euclid:
    JSON.opt_default = "JSON"

=item -[-][no]html5 | -[-][no]h5

Default on. Use --nohtml5 or --noh5 to skip this step.

Fetch a html5 template from http://www.initializr.com. Will only fetch
the Bootstrap version with defaults. Future versions may allow this to
be customized.

When downloaded it fills root/wrapper.tt2 with content from the
index.html from initializr.com and inserts [% content %] and touches
root/index.tt2.

=for Euclid:
    false: --nohtml5

=item --views

Short hand for saying --TT HTML and --JSON JSON

=item -[-]model [=] [<modelname>]

Package name to use for your model. If modelname not specified,
defaults to the catalyst name and "DB", ie "CatAppDB"

You can also put a dsn in here. It will then be reassigned to the
--dsn option, and the default model name will be used.

Note, *only* does DBIC::Schema.

=for Euclid:
  modelname.opt_default = "AppNameDB"

=item -[-]schema [=] <SchemaClass>

The name of the schema class to go with the dbic model. Defaults to
AppName::Schema.

=item -[-]dsn [=] <dsn>

A DSN to set up a db connection for one model in your catalyst app.

If user and pass are not specified it will try the dsn without
credentials. If it fails, it will prompt you for credentials unless
you specify --noninteractive.

=item -[-][no]dsnfix

Checks and corrects the dsn input

Fixes case of known drivers, adds missing leading dbi:, tries to
verify and correct sqlite file paths, checks that hostnames can be resolved

=for Euclid:
    false: --nodsnfix

=item -[-][no]pgpass

If set, will look in ~/.pgpass to complete dbi information.

Will currently only suplement the dsn if it finds a matching database
name.

It will set --dbuser and --dbpass as spropriate unless they are set.

=for Euclid:
    false: --nopgpass

=item -[-]dbuser [=] <dbuser>

Username for the db connection.

=item -[-]dbpass [=] <dbpass>

Db for the db connection.

=item -[-]pgpass

Causes it to look through $HOME/.pgpass for credentials for postgresql
connections.

=item -[-][no]test

Run all tests when done

=for Euclid:
    false: --notest

=item -[-]debug | -d

Set debug level for logging.

Currently there is no other interface to log level.

=item --verbose

Run more verbosely - shows stdout on all system calls made. Stderr is
always shown.

=item --version | -V

Prints version

=back

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

App::CatalystStarter::Bloated requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-app-catalyststarter-bloated@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Torbjørn Lindahl  C<< <torbjorn.lindahl@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, Torbjørn Lindahl C<< <torbjorn.lindahl@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
