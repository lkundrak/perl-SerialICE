#!/usr/bin/perl

=head1 NAME

B<replay-server.pl> - Replay a SerialICE trace against a SerialICE client

=head1 SYNOPSIS

qemu-0.15.x/i386-softmmu/qemu -M serialice -serialice /dev/ttyS0 -hda /dev/zero -bios 68VGU.BIN >serialice.log

replay-server.pl serialice.log ./replay-client.pl {} serialice.log

replay-server.pl serialice.log qemu-0.15.x/i386-softmmu/qemu -M serialice -serialice {} -hda /dev/zero -bios 68VGU.BIN

=head1 DESCRIPTION

This tools allows simulating a SerialICE server machine, replaying the
SerialICE traffic from a log. Useful when debugging a LUA script for actual
SerialICE, etc.

=cut

use strict;
use warnings;

use SerialICE::Server::Replay;
use IO::Pty;

autoflush STDOUT 1;

my $pty = new IO::Pty;
autoflush $pty 1;
$pty->slave->set_raw;
$pty->set_raw;

my $file = shift @ARGV;
my @EXEC = map { /^{}$/ ? $pty->ttyname : $_ } @ARGV;
die unless @EXEC;

open (my $capture, '+<', $file) or die "$file: $!";

my $pid = fork;
die "fork: $!" unless defined $pid;
$SIG{CHLD} = sub { exit $? if waitpid (-1, 0) == $pid };

END { kill $pid if defined $pid }

if ($pid) {
	my $ss = new SerialICE::Server::Replay ({
		capture => $capture,
		port => $pty,
		dry => 0,
		trace => 0,
		echo => 1,
	});

	$ss->run;
	waitpid ($pid, 0);
} else {
	undef $pty;
	undef $capture;
	undef $SIG{CHLD};
	exec @EXEC;
	die $!;
}

=head1 AUTHOR

Lubomir Rintel <lkundrak@v3.sk>

Distributed under the terms of GPL, any version.

=cut
