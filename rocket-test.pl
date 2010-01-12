#!/usr/local/bin/perl -w
###########################################
# rocket-test - USB-Raketenwerfer testen
# Mike Schilli, 2009 (m@perlmeister.com)
###########################################
use strict;

use Time::HiRes qw(usleep);
use Device::USB;
my $usb = Device::USB->new;
my $dev = $usb->find_device(0xA81, 0x701);
$dev->open;

  # Move Up
my $val = 0x02;
$dev->control_msg(0x21, 0x09, 0x02, 0, 
                      chr($val), 1, 1000);

usleep(150_000);

  # Stop
$val = 0x20;
$dev->control_msg(0x21, 0x09, 0x02, 0,
                      chr($val), 1, 1000);

  # Read status
$val = 0x40;
my $buf;
$dev->control_msg(0x21, 0x09, 0x02, 0, 
                      chr($val), 1, 1000);
$dev->bulk_read(1, $buf = "", 1, 1000);
printf "Status %08b\n", ord($buf);
