#!/usr/bin/perl

=head1 NAME

B<replay-client.pl> - Replay a SerialICE trace against the SerialICE server machine

=head1 SYNOPSIS

qemu-0.15.x/i386-softmmu/qemu -M serialice -serialice /dev/ttyS0 -hda /dev/zero -bios 68VGU.BIN >serialice.log

replay-client.pl /dev/ttyS0 serialice.log

replay-server.pl serialice.log ./replay-client.pl {} serialice.log

=head1 DESCRIPTION

This tools allows for replaying the SerialICE traffic from a log. Useful when
testing various modifications to the traffice against a real machine, etc.

=cut

use strict;
use warnings;

use SerialICE::Client::Replay;

autoflush STDOUT 1;

my $file;

$file = shift @ARGV // '/dev/ttyS0';
open (my $port, '+<', $file) or die "$file: $!";

$file = shift @ARGV;
my $capture;
if ($file) {
	open ($capture, '+<', $file) or die "$file: $!";
}

my $sc = new SerialICE::Client::Replay ({
	capture => $capture,
	port => $port,
	trace => 0,
});

$sc->run;

=head1 AUTHOR

Lubomir Rintel <lkundrak@v3.sk>

Distributed under the terms of GPL, any version.

=cut
