package App::CatalystStarter::Bloated;

use v5.10.1;

use utf8::all;
use warnings;
use strict;
use autodie;
use Carp;

use version; our $VERSION = qv('0.0.1');

use IO::Prompter;
use File::Which qw(which);
use File::Glob q(:bsd_glob);
use Path::Tiny qw(path cwd);
use Capture::Tiny qw(capture_stdout capture);
use DBI;
use Time::HiRes qw/ualarm/;
use Sys::SigAction qw(timeout_call);

use List::Util qw/first/;
use List::MoreUtils qw/all/;

use Log::Log4perl qw/:easy/;

use App::CatalystStarter::Bloated::Initializr;

my $cat_dir;
my $logger = get_logger;
sub l{$logger}

sub import {

    shift;
    if (defined $_[0] and $_[0] eq ":test") {
        Log::Log4perl->easy_init($FATAL);
    }
    elsif ($ARGV{'--debug'}) {
        Log::Log4perl->easy_init($DEBUG);
    }
    else {
        Log::Log4perl->easy_init($INFO);
    }

    l->debug( "Log level set to DEBUG" );

}

## a helper for easy access to paths
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
} ## catalyst_path.t
sub _set_cat_dir {
    $cat_dir = $_[0] if defined $_[0];
    return $cat_dir;
}
sub _creater {

    my($s) = path($cat_dir, "script")->children(qr/create\.pl/);
    l->debug("located creater script $s" );

    return $s;

} ## creater.t
sub _run_system {

    my @args = @_;

    my ($o,$e,@r);

    if ( $ARGV{"--verbose"} ) {
        l->debug("system call [verbose]: @args");
        system @args;
    }
    else {
        l->debug("system call: @args");
        ($o,$e,@r) = capture { system @args };
    }

    ## some known sdterr lines we do not show:
    my @e = split /\n/, $e;
    my @e2 = @e;
    @e2 = grep !/^Dumping manual schema for/, @e2;
    @e2 = grep !/^Schema dump completed\./, @e2;

    print $_,"\n" for @e2;

}
sub _finalize_argv {

    my $dsn_0 = $ARGV{'--dsn'};

    ## some booleans default on
    if ( not $ARGV{'--nodsnfix'} ) {
        $ARGV{'--dsnfix'} = $ARGV{'-dsnfix'} = 1
    }

    if ( not $ARGV{'--nopgpass'} ) {
        $ARGV{'--pgpass'} = $ARGV{'-pgpass'} = 1
    }

    if ( not $ARGV{'--nohtml5'}) {
        @ARGV{qw/-html5 --html5 -h5 --h5/} = (1)x4;
    }
    ## defaults done

    ## views triggers json and tt
    if ( $ARGV{'--views'} ) {
        my %map;
        @map{qw/-TT --TT -JSON --JSON/} = qw/HTML HTML JSON JSON/;
        for (qw/-TT --TT -JSON --JSON/) {
            $ARGV{$_} ||= $map{$_};
        }
    }

    ## model can have the dsn
    if (defined $ARGV{'--model'} and $ARGV{'--model'} =~ /^dbi:/i ) {
        $ARGV{'--dsn'} = $ARGV{'--model'};
        $ARGV{'--model'} = 1;
    }

    ## dsn gets a brush up
    if ($ARGV{'--dsn'}) {

        if ( $ARGV{'--dsnfix'} ) {
            $ARGV{'--dsn'} = _prepare_dsn( $ARGV{'--dsn'} );
            $ARGV{'-dsn'} = $ARGV{'--dsn'};
        }

        if ( not defined $ARGV{'--model'} ) {
            $ARGV{'--model'} = 1;
        }

    }

    ## model might have defaults
    if ( $ARGV{'--model'} ) {

        if ( $ARGV{'--model'} eq '1' ) {
            $ARGV{'--model'} = $ARGV{'--name'} . 'DB';
        }

        $ARGV{'--model'} =~ s/^AppNameDB$/$ARGV{'--name'}DB/;
        $ARGV{'-model'} = $ARGV{'--model'};

        if ( not $ARGV{'--schema'} or $ARGV{'--schema'} eq "1" ) {
            $ARGV{'--schema'} = $ARGV{'--name'} . '::Schema';

            $ARGV{'-schema'} = $ARGV{'--schema'};

        }

    }
    else {
        delete $ARGV{'--schema'};
        delete $ARGV{'-schema'};
    }

    $ARGV{'--dbuser'} //= "";
    $ARGV{'--dbpass'} //= "";

    if ( $dsn_0 ne $ARGV{'--dsn'} ) {
        l->debug( "dsn changed to '$ARGV{'--dsn'}'" );
    }

} ## finalize_argv.t

## dsn related
sub _prepare_dsn {

    my $dsn = shift;

    ## unlikely but guess it could happen
    l->info("Prepended litteral 'dbi' to dsn") if $dsn =~ s/^:/dbi:/;

    ## if it doesn't start with dbi: by now, we'll nicely provide that
    if ( lc substr( $dsn, 0, 4 ) ne "dbi:" ) {
        l->info("Prepended 'dbi:' to dsn");
        $dsn = "dbi:" . $dsn;
    }

    ## taking care of case, should there be issues
    l->info("Setting dsn scheme to lowercase 'dbi:'" )
        if $dsn =~ /^.{0,2}[DBI]/;
    $dsn =~ s/^dbi:/dbi:/i;

    ## if it doesn't end with a ":" but has one alerady, we'll append
    ## one, should be enough to make it parseable by DBI, ie dbi:Pg
    ## will do
    if ( $dsn =~ y/:// == 1 and $dsn =~ /^dbi:/ and $dsn !~ /:$/ ) {
        l->info("Appending ':' to make dsn valid");
        $dsn .= ":";
    }

    ## offer to correct the driver
    my @parts = DBI->parse_dsn( $dsn );
    my $driver = _fix_dbi_driver_case( $parts[1] );

    my $case_fixed_dsn = sprintf(
        "%s:%s%s:%s",
        $parts[0],
        $driver, $parts[2]||"",
        $parts[4]
    );

    my $pgpass_fixed_dsn = _complete_dsn_from_pgpass($case_fixed_dsn);
    return $pgpass_fixed_dsn;

} ## dsn.t
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

} ## dsn.t
sub _parse_dsn {

    my $dsn = shift ;

    my @parsed = DBI->parse_dsn($dsn);

    my $driver = _fix_dbi_driver_case($parsed[1]);

    my %hash = (driver => $driver, scheme => $parsed[0],
            attr_string => $parsed[2]);

    my %extra = _parse_dbi_dsn($parsed[4]);

    %hash = (%hash, %extra);

    return %hash;

} ## dsn.t
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
} ## fix_dbi_driver_case.t
sub _dsn_hash_to_dsn_string {
    my %dsn_hash = @_;

    my %dsn_last_part = %dsn_hash;
    my @first_parts = delete @dsn_last_part{qw/scheme driver attr_string/};
    $_ //= "" for @first_parts;

    my $last_part = "";
    while ( my($k,$v) = each %dsn_last_part ) {
        next if not defined $v or $v eq "";
        $last_part .= "$k=$v;";
    }
    $last_part =~ s/;$//;

    my $fixed_dsn = sprintf(
        "%s:%s%s:%s",
        @first_parts,
        $last_part
    );

    return $fixed_dsn;

}

## pgpass functions
sub _parse_pgpass {

    open my $fh, "<", path("~/.pgpass");

    my @entries;

    while ( <$fh> ) {
        chomp;
        my @values = split /:/, $_;

        my %row;
        @row{qw/host port database user pass/} = @values;

        ## not sure if this can ever happen
        $row{port} //= 5432;

        push @entries, \%row;

    }

    l->info(sprintf "Parsed %d entries from ~/.pgpass",
        scalar @entries );

    return @entries;

} ## pgpass.t
sub _pgpass_entry_to_dsn {

    my $entry = shift;
    my $dsn = "dbi:Pg:";

    if ( my $d = $entry->{database} ) {
        $dsn .= "database=" . $d . ";";
    }
    if ( my $h = $entry->{host} ) {
        ## don't add if it's localhost
        $dsn .= "host=" . $h . ";" if $h !~ /^localhost(?:$|\.)/;
    }
    if ( my $p = $entry->{port} ) {
        ## don't add if its default 5432
        $dsn .= "port=" . $p . ";" if $p != 5432;
    }

    $dsn =~ s/;$//;

    return $dsn;

} ## pgpass.t
sub _complete_dsn_from_pgpass {

    my $dsn = shift;

    ## return unless there is a ~/.pgpass
    my @pgpass = _parse_pgpass or return $dsn;

    my %dsn = _parse_dsn( $dsn );

    ## only works with pg for obvious reasons
    if ( $dsn{driver} ne "Pg") {
        return $dsn;
    }

    ## if all is already set, no point to linger
    if ( all {$_} (@dsn{qw/database port host/},
                   @ARGV{qw/--dbuser --dbpass/})  ) {
        return $dsn;
    }

    my @candidate_pgpass =
        do {

            grep {

                my $entry = $_;

                all {

                    # my $test = (not defined $dsn{$_} or
                    #     ($dsn{$_}||"") eq ($entry->{$_}||""));

                    # print "# $_; test is ", $test, "\n";

                    ## This allows flexible matching, as long as there
                    ## is one single match, it could be on anything of
                    ## host, db or port
                    not defined $dsn{$_} or
                        ($dsn{$_}||"") eq ($entry->{$_}||"");

                } qw/host database port/;

            } @pgpass;

        };

    if ( not @candidate_pgpass) {
        l->info("Found no pgpass entries, not adding to dsn");
        return $dsn;
    }
    elsif ( @candidate_pgpass == 1 ) {
        l->info("Using one matching pgpass entry to add to dsn");

        _fill_dsn_parameters_from_pgpass_data
            ( \%dsn, $candidate_pgpass[0] );

        $ARGV{'--dbuser'} //= $candidate_pgpass[0]->{user};
        $ARGV{'--dbpass'} //= $candidate_pgpass[0]->{pass};
    }
    # elsif ( @candidate_pgpass < 6 and not $ARGV{'--noconnectiontest'} ) {

    #     ## in future we will grep for working connections
    #     my @passed_candidates = grep {

    #     }

    # }
    else {
       ## too many matches, don't bother
        l->info( sprintf "Too many (%d) matching ~/.pgpass entries found - using none",
             scalar @candidate_pgpass );
        return $dsn;
    }

    return _dsn_hash_to_dsn_string( %dsn );

}
sub _fill_dsn_parameters_from_pgpass_data {

    ## $data is a single entry as parsed from .pgpass
    my( $dsn_hash, $data ) = @_;

    $dsn_hash->{$_} //= $data->{$_} for qw/host database port/;

}

# create functions
sub _mk_app {

    _run_system( "catalyst.pl" => $ARGV{"--name"} );
    l->info( sprintf "Created catalyst app '%s'", $ARGV{"--name"} );

    _set_cat_dir( $ARGV{"--name"} );

} ## mk_app.t
sub _create_TT {

    return unless my $tt = $ARGV{"--TT"};

    _run_system( _creater() => "view", $tt, "TT" );
    l->info( sprintf "Created TT view as %s::View::%s",
             @ARGV{qw/--name --TT/}
     );

} ## create.tt
sub _create_JSON {

    return unless my $json = $ARGV{"--JSON"};

    _run_system( _creater() => "view", $json, "JSON" );
    l->info( sprintf "Created JSON view as %s::View::%s",
             @ARGV{qw/--name --JSON/}
     );

} ## create_json.tt
sub _mk_views {

    if ( $ARGV{'--TT'} ) {
        _create_TT;
    }

    if ( $ARGV{'--JSON'} ) {
        _create_JSON;
    }

}
sub _mk_model {

    return unless my $model_name = $ARGV{'--model'};

    l->info(sprintf "Creating model; dsn=%s; model=%s; schema=%s",
            @ARGV{qw/--dsn --model --schema/}
        );

    _run_system( _creater() => "model", $model_name,
                 "DBIC::Schema", $ARGV{'--schema'},
                 "create=static",
                 @ARGV{qw/--dsn --dbuser --dbpass/},
             );

}

## This does it all
sub run {

    ## complete with logic not covered in G::E
    _finalize_argv;

    ## 1: Create a catalyst
    _mk_app;

    ## 2: Create views
    _mk_views;

    ## 3: Make model
    _mk_model;

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
