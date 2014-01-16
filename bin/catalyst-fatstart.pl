#!/usr/bin/perl

use utf8::all;
use strict;
use autodie;
use warnings;
use Carp qw< carp croak confess cluck >;

use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../lib";

use App::CatalystStarter::Bloated;

App::CatalystStarter::Bloated::_finalize_argv;

use Data::Dumper;
print Dumper \%ARGV;

__END__

=head1 NAME

catalyst-fatstart.pl - Catalyst starter that does more - for free

=head1 VERSION

This app and its module is currently at a puny version 0.0.1
