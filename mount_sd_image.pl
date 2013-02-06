#!/usr/bin/env perl

use warnings;
use strict;

my $filename = $ARGV[0];
my $mount_point = "$ARGV[0]_live";
my $go_code = $ARGV[1];
my $go = (defined($go_code) && $go_code eq "-f") ? 1 : 0;

my $offset = get_offset($filename);
make_mount_point($mount_point);
my $mount_cmd = "sudo mount -o loop,offset=$offset $filename $mount_point";

print $mount_cmd. "\n";

if($< == 0) {
    eval {
        system($mount_cmd);
    };
    if ($@) { 
        die "failed call to mount the loop device:  $mount_cmd";
    }
    print "image mounted at: $mount_point\n";
}
exit(0);


sub make_mount_point {
    my $mount_point = shift;
    unless(-d $mount_point) {
        mkdir $mount_point;
        unless(-d $mount_point) {
            die "Couldn't create mount point at: $mount_point\n";
        }
    }
}

sub get_offset {
    my $filename = shift;
    my @parted_out = `parted $filename unit b print`;
    @parted_out = grep { /ext3/ } @parted_out;
    my @data = split /\W+/, $parted_out[0];
    return substr($data[2], 0, -1);
}
