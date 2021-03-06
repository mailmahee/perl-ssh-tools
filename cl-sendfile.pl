#!/usr/bin/env perl
$|++;

###########################################################################
#                                                                         #
# Cluster Tools: cl-sendfile.pl                                           #
# Copyright 2007-2011, Albert P. Tobey <tobert@gmail.com>                 #
#                                                                         #
###########################################################################

=head1 NAME

cl-sendfile.pl - push a file over scp, in parallel

=head1 SYNOPSIS

Send files to cluster nodes.   This also archives those files in the /root/files to make tracking changes to the cluster
from default installs easier.

 cl-sendfile.pl -a -l /etc/httpd/conf/httpd.conf
 cl-sendfile.pl -d -l /tmp/foo.conf -r /usr/local/etc/foo.conf

 cl-sendfile.pl [-l $LOCAL_FILE] [-r $REMOTE_FILE] [-h] [-v] [--incl <pattern>] [--excl <pattern>]
        -l: local file/directory to rsync - passed through unmodified to rsync
        -r: remote location for rsync to write to - also unmodified
        -v: verbose output
        -h: print this message
=cut

use Pod::Usage;
use File::Temp qw/tempfile/;
use File::Basename;
use File::Copy;
use Getopt::Long;
use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;
use DshPerlHostLoop;

our $slaves           = undef;
our $local_file       = undef;
our $remote_file      = undef;
our $help             = undef;

GetOptions(
    "l=s" => \$local_file,
    "r=s" => \$remote_file,
    "n:i" => \$slaves,
    "h"   => \$help
);

if ( !$remote_file && $local_file && $local_file =~ m#^/# ) {
    $remote_file = $local_file;
}

unless ( ($local_file && $remote_file && -r $local_file) || $help ) {
    pod2usage();
}

# save all the files sent out to a local tree so it's easy to reproduce the cluster
#my $dir = dirname( $remote_file );
#system( "mkdir -p $ENV{HOME}/files/$dir" );
#copy( $local_file, "$ENV{HOME}/files/$remote_file" );

if ( $slaves ) {
    set_host_count( $slaves );
}

my $routine = sub {
    my $hostname = shift;
    scp( $local_file, "$hostname:$remote_file" );
};

func_loop( $routine );

# vim: et ts=4 sw=4 ai smarttab

__END__

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2007-2011 by Al Tobey.

This is free software; you can redistribute it and/or modify it under the terms
of the Artistic License 2.0.  (Note that, unlike the Artistic License 1.0,
version 2.0 is GPL compatible by itself, hence there is no benefit to having an
Artistic 2.0 / GPL disjunction.)  See the file LICENSE for details.

=cut
