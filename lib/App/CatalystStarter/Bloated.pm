package App::CatalystStarter::Bloated;

use utf8::all;
use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.1');

use IO::Prompter;
use File::Which qw/which/;
use File::Glob q(:bsd_glob);
use Path::Tiny qw/path cwd/;

my $cat_dir = cwd;

sub _finalize_argv {

    @ARGV{qw/-html5 --html5 -h5 --h5/} = (1)x4;

    if ( $ARGV{'--views'} ) {
        @ARGV{qw/-TT --TT -JSON --JSON/} = qw/HTML HTML JSON JSON/;
    }

}

# mainly needed for testing
sub _change_cat_dir {
    $cat_dir = $_[0];
}

sub _helper {

    my ($h) = path($cat_dir, "script")->children(qr/_create\.pl$/);
    return $h->relative($cat_dir);

}

## This does it all
sub run {

    ## complete with logic not covered in G::E
    _finalize_argv;



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
