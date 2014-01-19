package App::CatalystStarter::Bloated;

use utf8::all;
use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.1');

use IO::Prompter;
use File::Which qw(which);
use File::Glob q(:bsd_glob);
use Path::Tiny qw(path cwd);
use Capture::Tiny qw(capture_stdout);
use DBI;

use List::Util qw/first/;

my $cat_dir;

sub _catalyst_path {
    my $what = shift;
    my @extra;
    if ( $what eq "C" ) {
        @extra = ("lib", $ARGV{"--name"}, "Controller");
    }
    elsif ( $what eq "M" ) {
        @extra = ("lib", $ARGV{"--name"}, "Model");
    }
    elsif ( $what eq "V" ) {
        @extra = ("lib", $ARGV{"--name"}, "View");
    }
    else {
        @extra = ($what);
    }
    return path($cat_dir,@extra,@_)->absolute;
}
sub _set_cat_dir {
    $cat_dir = $_[0] if defined $_[0];
    return $cat_dir;
}
sub _creater {

    my($s) = path($cat_dir, "script")->children(qr/create\.pl/);
    return $s;

}
sub _run_system {

    my @args = @_;

    if ( $ARGV{"--verbose"} ) {
        system @args;
    }
    else {
        my $o = capture_stdout { system @args };
    }

}

sub _finalize_argv {

    if ( !$ARGV{nohtml5}) {
        @ARGV{qw/-html5 --html5 -h5 --h5/} = (1)x4;
    }

    if ( $ARGV{'--views'} ) {
        my %map;
        @map{qw/-TT --TT -JSON --JSON/} = qw/HTML HTML JSON JSON/;
        for (qw/-TT --TT -JSON --JSON/) {
            $ARGV{$_} ||= $map{$_};
        }
    }

    if (defined $ARGV{'--model'} and $ARGV{'--model'} =~ /^dbi:/i ) {
        $ARGV{'--dsn'} = $ARGV{'--model'};
        $ARGV{'--model'} = 1;
    }

    if ($ARGV{'--dsn'}) {
        $ARGV{'--dsn'} = _prepare_dsn( $ARGV{'--dsn'} );
        $ARGV{'-dsn'} = $ARGV{'--dsn'};
    }

    if ( $ARGV{'--model'} ) {

        if ( $ARGV{'--model'} eq "1" ) {
            $ARGV{'--model'} = $ARGV{"--name"} . "DB";
        }

        $ARGV{'--model'} =~ s/^AppNameDB$/$ARGV{"--name"}DB/;
        $ARGV{'-model'} = $ARGV{'--model'};
    }

}

## returns hash ref with: driver, database, host, port and anything
## else that might be there
sub _prepare_dsn {

    my $dsn = shift;

    ## unlikely but guess it could happen
    $dsn =~ s/^:/dbi:/;

    ## if it doesn't start with dbi: by now, we'll nicely provide that
    if ( lc substr( $dsn, 0, 4 ) ne "dbi:" ) {
        $dsn = "dbi:" . $dsn;
    }

    ## taking care of case, should there be issues
    $dsn =~ s/^dbi:/dbi:/i;

    ## if it doesn't end with a ":" but has one alerady, well append
    ## one, should be enough to make it parseable by DBI, ie dbi:Pg
    ## will do
    if ( $dsn =~ y/:// == 1 and $dsn =~ /^dbi:/ and $dsn !~ /:$/ ) {
        $dsn .= ":";
    }

    ## offer to correct the driver
    my @parts = DBI->parse_dsn( $dsn );
    my $driver = _fix_dbi_driver_case( $parts[1] );

    my $fixed_dsn = sprintf(
        "%s:%s%s:%s",
        $parts[0],
        $driver, $parts[2]||"",
        $parts[4]
    );

    return $fixed_dsn;

}
sub _parse_dbi_dsn {

    my $dsn = shift;

    return unless defined $dsn;

    my @pairs = split /;/, $dsn;

    my %data;

    for (@pairs) {
        my ($k,$v) = split /=/, $_;
        $data{$k} = $v;
    }

    my $db = first {$_} delete @data{qw/db database dbname/};
    $data{database} = $db;

    my $host = first {$_} delete @data{qw/host hostname/};
    $data{host} = $host;

    $data{port} //= undef;

    return %data;

}
sub _parse_dsn {

    my $dsn = _prepare_dsn shift ;

    my @parsed = DBI->parse_dsn($dsn);

    my $driver = _fix_dbi_driver_case($parsed[1]);

    my %hash = (driver => $driver);

    my %extra = _parse_dbi_dsn($parsed[4]);

    @hash{qw/database host port/} = @extra{qw/database host port/};

    return %hash;

}
sub _known_drivers {
    return qw/ ADO CSV DB2 DBM Firebird MaxDB mSQL mysql mysqlPP ODBC
               Oracle Pg PgPP PO SQLite SQLite2 TSM XBase /;
}
sub _fix_dbi_driver_case {
    my @args = @_;
    my %hash;
    $hash{ lc $_ } = $_ for _known_drivers;
    ($_ = $hash{lc $_} || $_) for @args;

    if (not wantarray and @args == 1) {
        return $args[0];
    }
    return @args;
}

# create functions
sub _mk_app {

    _run_system( "catalyst.pl" => $ARGV{"--name"} );

    _set_cat_dir( $ARGV{"--name"} );

}
sub _create_TT {

    return unless my $tt = $ARGV{"--TT"};

    _run_system( _creater() => "view", $tt, "TT" );

}
sub _create_JSON {

    return unless my $json = $ARGV{"--JSON"};

    _run_system( _creater() => "view", $json, "JSON" );

}
sub _create_model {



}

## This does it all
sub run {

    ## complete with logic not covered in G::E
    _finalize_argv;

    ## 1: Create a catalyst
    _mk_app;



}

1; # Magic true value required at end of module
__END__

=encoding utf8

=head1 NAME

App::CatalystStarter::Bloated - Tries really hard to set up all you
might need for a catalyst app.

=head1 VERSION

This document describes App::CatalystStarter::Bloated version 0.0.1

=head1 SYNOPSIS

    # dont use this module, use the installed script
    # catalyst-fatstart.pl instead

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE

=head2 run

The function that does it all.

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
