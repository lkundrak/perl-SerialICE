#!/usr/bin/perl

=head1 NAME

B<hp2133-emu.pl> - Emulate a HP Mini 2133 SerialICE server

=head1 SYNOPSIS

hp2133-emu.pl qemu-0.15.x/i386-softmmu/qemu -M serialice -serialice {} -hda /dev/zero -bios 68VGU.BIN

=head1 DESCRIPTION

This tools allows simulating a SerialICE HP Mini 2133 machine.

=cut

use strict;
use warnings;

use SerialICE::Server::Emu::Hp2133;
use IO::Pty;

autoflush STDOUT 1;

my $pty = new IO::Pty;
autoflush $pty 1;
$pty->slave->set_raw;
$pty->set_raw;

my @EXEC = map { /^{}$/ ? $pty->ttyname : $_ } @ARGV;
die unless @EXEC;

my $pid = fork;
die "fork: $!" unless defined $pid;
$SIG{CHLD} = sub { exit $? if waitpid (-1, 0) == $pid };

END { kill $pid if defined $pid }

if ($pid) {
	my $ss = new SerialICE::Server::Emu::Hp2133 ({
		port => $pty,
		dry => 0,
		trace => 0,
		echo => 1,
	});

	$ss->run;
	waitpid ($pid, 0);
} else {
	undef $pty;
	undef $SIG{CHLD};
	exec @EXEC;
	die $!;
}

=head1 AUTHOR

Lubomir Rintel <lkundrak@v3.sk>

Distributed under the terms of GPL, any version.

=cut
