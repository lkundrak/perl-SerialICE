#!/usr/bin/perl

=head1 NAME

B<hp2133-mem.pl> - Simulate a HP Mini 2133 for SerialICE with various memory configuration

=head1 SYNOPSIS

hp2133-mem.pl qemu-0.15.x/i386-softmmu/qemu -M serialice -serialice {} -hda /dev/zero -bios 68VGU.BIN

=head1 DESCRIPTION

This tools allows simulating a machine with different memory configurations
without having the physical modules or even slots.

=cut

use strict;
use warnings;

use utf8;

use SerialICE::Server::Emu::Hp2133;
use IO::Pty;

binmode STDOUT, ":utf8";

sub spd
{
	my $parm = shift;

	return {
		0x14 => $parm->{dimm_type},	# DIMM type of this assembly (bitmap)
		0x05 => $parm->{height_ranks},	# Vertical height & Ranks
		0x09 => $parm->{tCK_max},	# Clock cycle time at highest CAS latency
		0x0d => $parm->{width},		# Primary SDRAM width
		0x12 => $parm->{supported_CAS},	# CAS latencies supported (bitmap)
		0x17 => $parm->{tCK_medium},	# Clock cycle time at medium CAS latency
		0x19 => $parm->{tCK_short},	# Clock cycle time at short CAS latency
		0x11 => $parm->{banks},		# Banks per SDRAM device
		0x1b => $parm->{tRP_min},	# Minimum row precharge time (tRP)
		0x1d => $parm->{tRCD_min},	# Minimum RAS to CAS delay (tRCD)
		0x1e => $parm->{tRAS_min},	# Minimum active to precharge time (tRAS)
		0x1c => $parm->{tRRD_min},	# Minimum row active-row active delay (tRRD)
		0x26 => $parm->{tRTP},		# Internal read to precharge command delay (tRTP)
		0x25 => $parm->{tWTR},		# Internal write to read command delay (tWTR)
		0x24 => $parm->{tWR_min},	# Minimum write recovery time (tWR)
		0x2a => $parm->{tRFC_min},	# Minimum refresh to active/refresh time (tRFC)
	};
}

my %common = (
	dimm_type	=> 0x04,
	width		=> 0x08,
	supported_CAS	=> 0x70,
	tCK_max		=> 0x25,
	tCK_medium	=> 0x30,
	tCK_short	=> 0x3d,
	tRP_min		=> 0x3c,
	tRCD_min	=> 0x3c,
	tRAS_min	=> 0x2d,
	tRRD_min	=> 0x1e,
	tRTP		=> 0x1e,
	tWTR		=> 0x1e,
	tWR_min		=> 0x3c,
	tRFC_min	=> 0x7f,
);

sub spd_1rank_4bank
{
	return spd ({
		%common,
		height_ranks	=> 0x60,
		banks		=> 0x04,
	});
}

sub spd_1rank_8bank
{
	return spd ({
		%common,
		height_ranks	=> 0x60,
		banks		=> 0x08,
	});
}

sub spd_2rank_4bank
{
	return spd ({
		%common,
		height_ranks	=> 0x61,
		banks		=> 0x04,
	});
}

sub spd_2rank_8bank
{
	return spd ({
		%common,
		height_ranks	=> 0x61,
		banks		=> 0x04,
	});
}

sub new_ss
{
	my $smbus = shift;
	my $pty = new IO::Pty;
	autoflush $pty 1;
	$pty->slave->set_raw;
	$pty->set_raw;

	my @EXEC = map { /^{}$/ ? $pty->ttyname : $_ } @ARGV;
	die unless @EXEC;

	my $pid = fork;
	die "fork: $!" unless defined $pid;

	if ($pid) {
		my $ss = new SerialICE::Server::Emu::Hp2133 ({
			port => $pty,
			dry => 0,
			trace => 0,
			echo => 1,
		});

		$ss->{smbus} = $smbus if $smbus;

		$ss->run;
		close $pty;
		waitpid ($pid, 0);
		return $ss;
	} else {
		close STDOUT;
		undef $pty;
		undef $SIG{CHLD};
		exec @EXEC;
		die $!;
	}
}

my @r = (
	new SerialICE::Server::Emu::Hp2133,
	new_ss ({0x50 => spd_1rank_4bank,
		desc => '1 Rank 4 Bank' }),
	new_ss ({0x50 => spd_1rank_4bank, 0x51 => spd_1rank_4bank,
		desc => '1 Rank 4 Bank + 1 Rank 4 Bank' }),
	new_ss ({0x50 => spd_1rank_4bank, 0x51 => spd_1rank_8bank,
		desc => '1 Rank 4 Bank + 1 Rank 8 Bank' }),
	new_ss ({0x50 => spd_1rank_8bank, 0x51 => spd_1rank_8bank,
		desc => '1 Rank 8 Bank + 1 Rank 8 Bank' }),
	new_ss ({0x50 => spd_1rank_8bank,
		desc => '1 Rank 8 Bank' }),
	new_ss ({0x50 => spd_2rank_4bank,
		desc => '2 Rank 4 Bank' }),
	new_ss ({0x50 => spd_2rank_4bank, 0x51 => spd_2rank_4bank,
		desc => '2 Rank 4 Bank + 2 Rank 4 Bank' }),
	new_ss ({0x50 => spd_2rank_4bank, 0x51 => spd_2rank_8bank,
		desc => '2 Rank 4 Bank + 2 Rank 8 Bank' }),
	new_ss ({0x50 => spd_2rank_8bank, 0x51 => spd_2rank_8bank,
		desc => '2 Rank 8 Bank + 2 Rank 8 Bank' }),
	new_ss ({0x50 => spd_2rank_8bank,
		desc => '2 Rank 8 Bank' }),
	new_ss ({0x50 => spd_1rank_4bank, 0x51 => spd_2rank_4bank,
		desc => '1 Rank 4 Bank + 2 Rank 4 Bank' }),
	new_ss ({0x50 => spd_1rank_4bank, 0x51 => spd_2rank_8bank,
		desc => '1 Rank 4 Bank + 2 Rank 8 Bank' }),
	new_ss ({0x50 => spd_1rank_8bank, 0x51 => spd_2rank_8bank,
		desc => '1 Rank 8 Bank + 2 Rank 8 Bank' }),
	new_ss ({0x50 => spd_1rank_8bank, 0x51 => spd_2rank_4bank,
		desc => '1 Rank 8 Bank + 2 Rank 4 Bank' }),
);

foreach my $run (0..$#r + 1) {
	print ' ' x 4;
	print '│  ' x $run;
	print "┌─ ".($r[$run]->{smbus}{desc} // "(default)") if exists $r[$run];
	print "\n";
}

our %regs;
foreach my $reg (sort keys %{$r[0]->{pci}{'0:00.3'}}) {
	printf '%02x:', $reg;
	foreach my $run (@r) {
		my $val = $run->{pci}{'0:00.3'}{$reg};
		print ($val ? sprintf ' %02x', $val : ' --');
	};
	printf " │ %s\n", $regs{$reg};
}

BEGIN { %regs = (
	0x00 => 'Vendor ID',
	0x01 => 'Vendor ID',
	0x02 => 'Device ID',
	0x03 => 'Device ID',
	0x04 => 'PCI Command',
	0x05 => 'PCI Command',
	0x06 => 'PCI Status',
	0x07 => 'PCI Status',
	0x08 => 'Revision ID',
	0x09 => 'Class Code',
	0x0a => 'Class Code',
	0x0b => 'Class Code',
	0x0c => 'Reserved',
	0x0d => 'Latency Timer',
	0x0e => 'Header Type',
	0x0f => 'Built In Self Test (BIST)',
	0x10 => 'Reserved',
	0x11 => 'Reserved',
	0x12 => 'Reserved',
	0x13 => 'Reserved',
	0x2c => 'Subsystem Vendor ID',
	0x2d => 'Subsystem Vendor ID',
	0x2e => 'Subsystem ID',
	0x2f => 'Subsystem ID',
	0x30 => 'Reserved',
	0x31 => 'Reserved',
	0x32 => 'Reserved',
	0x33 => 'Reserved',
	0x34 => 'Capability Pointer',
	0x37 => 'Reserved',
	0x38 => 'Reserved',
	0x39 => 'Reserved',
	0x3a => 'Reserved',
	0x3b => 'Reserved',
	0x3c => 'Reserved',
	0x3d => 'Reserved',
	0x3e => 'Reserved',
	0x3f => 'Reserved',
	0x40 => 'DRAM Rank 0 Ending Address',
	0x41 => 'DRAM Rank 1 Ending Address',
	0x42 => 'DRAM Rank 2 Ending Address',
	0x43 => 'DRAM Rank 3 Ending Address',
	0x44 => 'Reserved',
	0x45 => 'Reserved',
	0x46 => 'Reserved',
	0x47 => 'Reserved',
	0x48 => 'DRAM Rank 0 Beginning Address',
	0x49 => 'DRAM Rank 1 Beginning Address',
	0x4a => 'DRAM Rank 2 Beginning Address',
	0x4b => 'DRAM Rank 3 Beginning Address',
	0x4c => 'Reserved',
	0x4d => 'Reserved',
	0x4e => 'Reserved',
	0x4f => 'Reserved',
	0x50 => 'DRAM MA Map Type',
	0x51 => 'DRAM MA Map Type',
	0x52 => 'Bank Interleave Address Select',
	0x53 => 'Bank / Rank Interleave Address Select - Channel A Only',
	0x54 => 'Physical-to-Virtual Rank Mapping 1',
	0x55 => 'Physical-to-Virtual Rank Mapping 2',
	0x56 => 'Physical-to-Virtual Rank Mapping 3',
	0x57 => 'Reserved',
	0x58 => 'Virtual Rank Interleave Address Select / Enable - Rank 0',
	0x59 => 'Virtual Rank Interleave Address Select / Enable - Rank 1',
	0x5a => 'Virtual Rank Interleave Address Select / Enable - Rank 2',
	0x5b => 'Virtual Rank Interleave Address Select / Enable - Rank 3',
	0x5c => 'Virtual Rank Interleave Address Select / Enable - Rank 0 of Channel B',
	0x5d => 'Reserved',
	0x5e => 'Reserved',
	0x5f => 'Reserved',
	0x60 => 'DRAM Pipeline Turn-Around Setting',
	0x61 => 'DRAM Timing for All Ranks 1',
	0x62 => 'DRAM Timing for All Ranks 2',
	0x63 => 'DRAM Timer for All Ranks 3',
	0x64 => 'DRAM Timer for All Ranks 4',
	0x65 => 'DRAM Arbitration Timer',
	0x66 => 'DRAM Queue / Arbitration',
	0x67 => 'DIMM Command / Address Selection',
	0x68 => 'DDR2 Page Control 1',
	0x69 => 'DDR2 Page Control 2',
	0x6a => 'Refresh Counter',
	0x6b => 'DRAM Miscellaneous Control',
	0x6c => 'DRAM Type',
	0x6d => 'DQ Channel Select',
	0x6e => 'DRAM Control',
	0x6f => 'Miscellaneous Control',
	0x70 => 'DQS Output Delay - Channel A',
	0x71 => 'MD Output Delay - Channel A',
	0x72 => 'Reserved',
	0x73 => 'Reserved',
	0x74 => 'DQS Output Clock Phase Control',
	0x75 => 'DQ Output Clock Phase Control',
	0x76 => 'Write Data Phase Control',
	0x77 => 'DQS Input Delay Calibration',
	0x78 => 'DQS Input Capture Range Control - Channel A',
	0x79 => 'Reserved',
	0x7a => 'DQS Input Capture Range Control',
	0x7b => 'Read Data Phase Control',
	0x7c => 'DQS Input Delay Offset Control - Channel A',
	0x7d => 'Reserved',
	0x7e => 'Reserved',
	0x7f => 'Reserved',
	0x80 => 'Page-C ROM Shadow Control',
	0x81 => 'Page-D ROM Shadow Control',
	0x82 => 'Page-E ROM Shadow Control',
	0x83 => 'Page-F ROM, Memory Hole and SMI Decoding',
	0x84 => 'Low Top Address - Low',
	0x85 => 'Low Top Address - High',
	0x86 => 'SMM and APIC Decoding',
	0x87 => 'Reserved',
	0x88 => 'The Address Next to the Last DRAM Bank Ending Address',
	0x89 => 'The Address Next to the Last DRAM Bank Ending Address',
	0x8a => 'Reserved',
	0x8b => 'Reserved',
	0x8c => 'DQS Output Control',
	0x8d => 'Reserved',
	0x8e => 'Reserved',
	0x8f => 'Reserved',
	0x90 => 'DRAM Clock Operation Mode and Frequency',
	0x91 => 'DCLK (MCLK) Phase Control',
	0x92 => 'CS/CKE Clock Phase Control',
	0x93 => 'SCMD/MA Clock Phase Control',
	0x94 => 'Reserved',
	0x95 => 'By-Rank Self Refresh Related Registers - Channel A',
	0x96 => 'By-Rank Self Refresh Related Registers - Channel A',
	0x97 => 'Reserved',
	0x98 => 'DRAM Channel Pipeline Control',
	0x99 => 'DCLKO (MCLK) Phase Control',
	0x9a => 'Reserved',
	0x9b => 'DRAM MD PADs ODTA[7:4] Pullup / Pulldown Control',
	0x9c => 'ODT Lookup Table - Channel A',
	0x9d => 'Reserved',
	0x9e => 'SDRAM ODT Control 1',
	0x9f => 'SDRAM ODT Control 2',
	0xa0 => 'CPU Direct Access Frame Buffer Control',
	0xa1 => 'CPU Direct Access Frame Buffer Control',
	0xa2 => 'VGA Timer 1',
	0xa3 => 'Reserved',
	0xa4 => 'GFX Misc.',
	0xa5 => 'GFX Misc.',
	0xa6 => 'Page Register Life Timer 1 in CPU Power Saving States',
	0xa7 => 'GMINT (GFX-Memory Interface) and GFX Related Register',
	0xa8 => 'Reserved',
	0xa9 => 'Reserved',
	0xaa => 'Reserved',
	0xab => 'Reserved',
	0xac => 'Reserved',
	0xad => 'Reserved',
	0xae => 'Reserved',
	0xaf => 'Reserved',
	0xb0 => 'GMINT Misc. 1',
	0xb1 => 'GMINT Misc. 1',
	0xb2 => 'AGPCINT Misc.',
	0xb3 => 'GMINT Misc. 2',
	0xb4 => 'EPLL Register',
	0xb5 => 'Reserved',
	0xb6 => 'Reserved',
	0xb7 => 'Reserved',
	0xb8 => 'Reserved',
	0xb9 => 'Reserved',
	0xba => 'Reserved',
	0xbb => 'Reserved',
	0xbc => 'Reserved',
	0xbd => 'Reserved',
	0xbe => 'Reserved',
	0xbf => 'Reserved',
	0xd0 => 'DQ / DQS Termination Strength Manual Control',
	0xd1 => 'DQ / DQS Termination Strength Auto-Comp Status',
	0xd2 => 'DQ Driving Strength Auto-Comp Status',
	0xd3 => 'Compensation Control',
	0xd4 => 'ODT Pullup / Pulldown Control',
	0xd5 => 'DQ / DQS Burst Function and ODT Range Select',
	0xd6 => 'DCLK / SCMD / CS Driving Select',
	0xd7 => 'SCMD/MA Burst Function',
	0xd8 => 'DCLKI Termination Strength',
	0xd9 => 'Reserved',
	0xda => 'Reserved',
	0xdb => 'Operation Mode Control - Channel C',
	0xdc => 'Timing Parameters Control - Channel C',
	0xdd => 'PADs Power-Down Control - Channel C',
	0xde => 'GMINT\'s Merge Function',
	0xdf => 'Write Cycle Timing Control - Channel C',
	0xe0 => 'DRAM Driving - Group DQSA',
	0xe1 => 'DRAM Driving - Group DQSB',
	0xe2 => 'DRAM Driving - Group DQA (MD, DQS, DQM)',
	0xe3 => 'DRAM Driving - Group DQB (MD, DQS, DQM)',
	0xe4 => 'DRAM Driving - Group CSA (CS, DQM)',
	0xe5 => 'DRAM Driving - Group CSB (CS, DQM)',
	0xe6 => 'DRAM Driving - Group MCLKA',
	0xe7 => 'DRAM Driving - Group MCLKB',
	0xe8 => 'DRAM Driving - Group SCMDA/MAA',
	0xe9 => 'DRAM Driving - Group SCMDB/MAB',
	0xea => 'Reserved',
	0xeb => 'Reserved',
	0xec => 'Channel-A DQS / DQ CKG Output Duty Cycle Control',
	0xed => 'DQS / DQ CKG Output Duty Cycle Control - Channel C',
	0xee => 'DCLK Output Duty Control',
	0xef => 'DQ CKG Input Delay Control',
	0xf0 => 'DQ/DQS CKG Output Delay Control - Channel A',
	0xf1 => 'DQ/DQS CKG Output Delay Control - Channel A',
	0xf2 => 'DQ/DQS CKG Output Delay Control - Channel A',
	0xf3 => 'DQ/DQS CKG Output Delay Control - Channel A',
	0xf4 => 'DQ/DQS CKG Output Delay Control - Channel C',
	0xf5 => 'DQ/DQS CKG Output Delay Control - Channel C',
	0xf6 => 'DQ/DQS CKG Output Delay Control - Channel C',
	0xf7 => 'DQ/DQS CKG Output Delay Control - Channel C',
	0xf8 => 'DRAM Mode Register Setting (MRS) Control - DRAM Channel C (DRAMCC)',
	0xf9 => 'DRAM Mode Register Setting (MRS) Control - DRAM Channel C (DRAMCC)',
	0xfa => 'DQ De-Skew Function Control',
	0xfb => 'Power Management  - Channel A',
	0xfc => 'Reserved',
	0xfd => 'Power Management 1',
	0xfe => 'Power Management 2',
	0xff => 'DQS Input Delay of Channel C and Registers for STR Mode',
)}

=head1 AUTHOR

Lubomir Rintel <lkundrak@v3.sk>

Distributed under the terms of GPL, any version.

=cut
