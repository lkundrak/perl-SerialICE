package SerialICE::Server::Emu::Hp2133;

use strict;
use warnings;

use SerialICE::Server::Emu;
use base qw/SerialICE::Server::Emu/;

sub init_mem
{
	my $self = shift;

	$self->{mem} = {
		0xfed60008 => 0x00,
		0xfec00000 => undef,
		0xfec00010 => undef,
		0xfec00011 => undef,
		0xfec00012 => undef,
		0xfec00013 => undef,
		0xfecc0000 => undef,
		0xfecc0010 => undef,
		0xfecc0011 => undef,
		0xfecc0012 => undef,
		0xfecc0013 => undef,
	};
}

sub init_cmos
{
	my $self = shift;

	$self->{cmos} = {
		0x10 => 0x40, 0x11 => 0x30, 0x12 => 0x00, 0x13 => 0x30,
		0x14 => 0x0e, 0x15 => 0x80, 0x16 => 0x02, 0x17 => 0xff,
		0x18 => 0xff, 0x19 => 0x00, 0x1a => 0x00, 0x1b => 0x00,
		0x1c => 0x00, 0x1d => 0x00, 0x1e => 0x00, 0x1f => 0x00,
		0x20 => 0x00, 0x21 => 0x00, 0x22 => 0x00, 0x23 => 0x00,
		0x24 => 0x00, 0x25 => 0x00, 0x26 => 0x00, 0x27 => 0x00,
		0x28 => 0x00, 0x29 => 0x30, 0x2a => 0x47, 0x2b => 0x47,
		0x2c => 0x47, 0x2d => 0x47, 0x2e => 0x04, 0x2f => 0x7a,
		0x37 => 0x00, 0x3a => 0x00, 0x3b => 0x00, 0x3c => 0x30,
		0x3d => 0x00, 0x3e => 0x1e, 0x3f => 0x60, 0x40 => 0x00,
		0x41 => 0x00, 0x42 => 0x00, 0x43 => 0x00, 0x44 => 0x00,
		0x45 => 0x00, 0x46 => 0x00, 0x47 => 0x00, 0x48 => 0x00,
		0x49 => 0x00, 0x4a => 0x00, 0x4b => 0x00, 0x4c => 0x00,
		0x4d => 0xff, 0x4e => 0xff, 0x4f => 0xff, 0x50 => 0xff,
		0x51 => 0xff, 0x52 => 0x40, 0x53 => 0xff, 0x54 => 0x00,
		0x55 => 0x00, 0x56 => 0xff, 0x57 => 0xff, 0x58 => 0xff,
		0x59 => 0xff, 0x5a => 0xff, 0x5b => 0x4d, 0x5c => 0x43,
		0x5d => 0x5e, 0x5e => 0x1e, 0x5f => 0x80, 0x60 => 0xd5,
		0x61 => 0x0f, 0x62 => 0x0c, 0x63 => 0x00, 0x64 => 0x00,
		0x65 => 0x00, 0x66 => 0x00, 0x67 => 0x10, 0x68 => 0x31,
		0x6a => 0x54, 0x6b => 0x76, 0x6c => 0x98, 0x6d => 0xba,
		0x6e => 0x10, 0x6f => 0x32, 0x70 => 0x54, 0x71 => 0x76,
		0x72 => 0x98, 0x73 => 0xba, 0x74 => 0x72, 0x75 => 0x07,
		0x76 => 0x00, 0x77 => 0x00, 0x78 => 0x70, 0x8b => 0x02,
		0x8e => 0x00, 0xb5 => 0x33, 0xb6 => 0x06, 0xd4 => 0x00,
	};
}

sub init_cmos2
{
	my $self = shift;

	$self->{cmos2} = {
		0x0a => 0x26, 0x0e => 0x00, 0x39 => 0xfe, 0x80 => 0x80,
		0x81 => 0x38, 0x82 => 0x01, 0x83 => 0x00, 0x84 => 0x08,
		0x85 => 0x1a, 0x86 => 0x08, 0x87 => 0x1a, 0x88 => 0x00,
		0x89 => 0x00, 0x8a => 0x00, 0x8b => 0x00, 0x8c => 0x08,
		0x8d => 0x32, 0x8e => 0x2c, 0x8f => 0x00, 0x90 => 0x40,
		0x91 => 0x40, 0x92 => 0xc0, 0x93 => 0xb0, 0x94 => 0xaa,
		0x95 => 0x49, 0x96 => 0x01, 0x97 => 0xa4, 0x98 => 0x98,
		0x99 => 0x02, 0x9a => 0xfd, 0x9b => 0x07, 0x9c => 0x6e,
		0x9d => 0xe8, 0x9e => 0x44, 0x9f => 0x3d, 0xa0 => 0xa6,
		0xa1 => 0x27, 0xa2 => 0x02, 0xa3 => 0x82, 0xa4 => 0x9b,
		0xa5 => 0xdf, 0xa6 => 0x47, 0xa7 => 0x3e,
	};
}

sub init_smbus
{
	my $self = shift;

	my @spd = map { hex $_ } qw/
		80 08 08 0e 0a 61 40 00 05 25 40 00 82 08 00 00
		0c 08 70 01 04 00 07 30 45 3d 50 3c 1e 3c 2d 01
		17 25 05 12 3c 1e 1e 00 06 3c 7f 80 14 1e 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 e3
		ad 00 00 00 00 00 00 00 01 48 59 4d 50 31 32 35
		53 36 34 43 50 38 2d 53 36 20 20 41 41 09 53 4f
		62 77 3a 00 00 00 00 00 00 00 00 00 00 00 00 54
		46 39 43 4e 46 38 35 34 32 30 32 00 00 00 00 00
		49 4e 54 45 4c 00 00 00 00 00 00 00 00 00 00 02
		4f 2e 45 2e 4d 2e 6f 67 61 00 00 00 00 00 00 00
		01 03 01 03 03 07 00 00 00 00 00 00 00 02 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	/;

	$self->{smbus} = {
		0x50 => { map { $_ => $spd[$_] } 0..$#spd },
		#0x51 => { map { $_ => $spd[$_] } 0..$#spd },
	};
}

sub init_pci
{
	my $self = shift;

	$self->{pci} = {
		'0:00.0' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x4f => 0x01,
		},
		'0:00.1' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
		},
		'0:00.2' => {
			0x64 => undef, 0x65 => undef, 0x66 => undef, 0x67 => undef,
			0x70 => undef, 0x71 => undef, 0x72 => undef, 0x73 => undef,
			0x74 => undef, 0x75 => undef, 0x76 => undef, 0x77 => undef,
			0x78 => undef, 0x79 => undef, 0x7a => undef, 0x7b => undef,
			0x7c => undef, 0x7d => undef, 0x80 => undef, 0x81 => undef,
			0x82 => undef, 0x83 => undef, 0x2c => undef, 0x2d => undef,
			0x2e => undef, 0x2f => undef, 0x50 => 0x80,  0x51 => 0x00,
			0x52 => 0x20,  0x53 => 0x00,
			0x54 => sub {
				my $val;

				sub {
					return $val unless @_;
					$val = shift | 0x60;
				}
			}->(),
			0x55 => 0x00,
			0x57 => sub {
				my $val = 0x00;

				sub {
					return $val unless @_;
					$val = shift;
					$val = 0xb9 if $val == 0x19;
				}
			}->(),
			0x59 => 0xc0,  0x5d => 0x00,  0x5e => 0x00,
			0x5f => 0x00,  0x60 => undef, 0x61 => undef, 0x62 => undef,
			0x63 => undef,
		},
		'0:00.3' => {
			0x64 => undef, 0x65 => undef, 0x67 => 0x00,  0x68 => 0x00,
			0x69 => 0x82,  0x6a => undef, 0x6b => 0x10,  0x6c => 0x40,
			0x6d => undef, 0x6e => undef, 0x6f => undef, 0x70 => undef,
			0x71 => undef, 0x74 => undef, 0x75 => undef, 0x76 => undef,
			0x77 => undef, 0x78 => undef, 0x79 => undef, 0x7a => undef,
			0x7b => 0x00,  0x80 => 0x00,  0x81 => 0x00,  0x82 => 0x00,
			0x83 => 0x00,  0x84 => undef, 0x85 => undef, 0x86 => 0x01,
			0x88 => 0x80,  0x89 => 0x00,  0x8c => undef, 0x90 => 0x00,
			0x91 => undef, 0x92 => undef, 0x93 => undef, 0x94 => 0x00,
			0x98 => 0x00,  0x9c => 0x00,  0x9e => 0x00,  0x9f => 0x00,
			0xa1 => undef, 0xa4 => 0x00,  0xb0 => 0x00,  0xb2 => 0x00,
			0xd0 => undef, 0xd3 => undef, 0xd4 => undef, 0xd5 => 0x00,
			0xd6 => 0x80,  0xe0 => undef, 0xe2 => undef, 0xe4 => undef,
			0xe6 => undef, 0xe8 => undef, 0xec => undef, 0xee => undef,
			0xef => undef, 0xfa => undef, 0xfb => 0x00,  0x40 => undef,
			0x41 => undef, 0x42 => undef, 0x43 => undef, 0x48 => undef,
			0x49 => undef, 0x4a => undef, 0x4b => undef, 0x50 => undef,
			0x51 => undef, 0x52 => undef, 0x53 => undef, 0x54 => 0x81,
			0x55 => 0x23,  0x56 => undef, 0x57 => undef, 0x60 => undef,
			0x61 => undef, 0x62 => undef, 0x63 => undef,
		},
		'0:00.4' => {
			0xb2 => undef, 0xd9 => undef, 0xf6 => 0x08,  0x2c => undef,
			0x2d => undef, 0x2e => undef, 0x2f => undef, 0x40 => 0x00,
		},
		'0:00.5' => {
			0xf0 => 0x62,  0x2c => undef, 0x2d => undef, 0x2e => undef,
			0x2f => undef, 0x40 => 0x4c,  0x42 => 0x03,  0x60 => 0x20,
		},
		'0:00.6' => {
			0x68 => 0x00,  0x69 => 0x00,  0x70 => undef, 0x71 => undef,
			0x72 => 0x00,  0x73 => 0x00,  0x78 => undef, 0x79 => undef,
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x44 => undef, 0x46 => undef, 0x47 => 0x00,  0x49 => undef,
			0x4d => undef, 0x4e => undef, 0x4f => undef, 0x50 => undef,
			0x55 => undef, 0x56 => undef, 0x58 => undef, 0x59 => undef,
			0x5a => 0x00,  0x5b => 0x00,  0x60 => 0x00,  0x61 => 0x00,
		},
		'0:00.7' => {
			0xe6 => 0x00,  0x47 => undef,
			0x48 => sub { 0x00 },
		},
		'0:02.0' => {
			0x73 => 0x01,  0xa3 => 0xfc,  0xa4 => 0x5c,  0xa7 => 0x04,
			0xc2 => 0x27,  0xe0 => 0x0c,  0xe1 => 0x07,  0xe2 => 0x81,
			0xe3 => 0x9a,  0xe4 => 0x88,  0xe8 => 0x81,  0xe9 => 0x82,
			0xea => 0x88,  0x3d => 0x01,  0x4d => 0x3d,  0x5a => 0x00,
		},
		'0:03.0' => {
			0x73 => 0x01,  0xa2 => 0x30,  0xa3 => 0x7c,  0xa7 => 0x04,
			0xe1 => 0x0b,  0xe2 => 0x01,  0xe3 => 0x9a,  0xe4 => 0x88,
			0x3d => 0x01,  0x4d => 0x3c,
		},
		'0:0f.0' => {
			0x0a => undef, 0xd2 => undef, 0xd3 => undef, 0xd4 => undef,
			0xd5 => undef, 0xd6 => undef, 0xd7 => undef, 0x45 => 0xaf,
		},
		'0:0f.1' => {
			0xd4 => undef, 0xd5 => undef, 0xd6 => undef, 0xd7 => undef,
		},
		'0:10.0' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x42 => 0x03,
		},
		'0:10.1' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x42 => 0x03,
		},
		'0:10.2' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x42 => 0x03,
		},
		'0:10.3' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x42 => 0x03,
		},
		'0:10.4' => {
			0x2c => undef, 0x2d => undef, 0x2e => undef, 0x2f => undef,
			0x42 => 0x03,
		},
		'0:11.0' => {
			0x67 => 0x04,  0x68 => 0x00,  0x69 => 0x00,  0x6a => 0x00,
			0x6b => 0x00,  0x70 => undef, 0x71 => undef, 0x72 => undef,
			0x73 => undef, 0x7b => 0x00,  0x80 => 0x00,  0x81 => 0x04,
			0x82 => 0x50,
			0x88 => sub { 0x01 },
			0x89 => undef, 0x8c => 0x07,
			0x93 => 0x00,  0x94 => 0x80,  0x95 => 0x40,  0x98 => 0x10,
			0xbc => 0x00,  0xbd => 0x00,  0xbe => 0x00,  0xd0 => 0x01,
			0xd1 => 0x00,  0xd2 => 0x00,  0xe0 => 0x00,  0xe4 => 0x00,
			0xe5 => 0x40,  0xe6 => 0x08,  0xe7 => 0x00,  0xe8 => 0x00,
			0xe9 => 0x00,  0xea => 0x00,  0xeb => 0x00,  0xec => 0x00,
			0xf6 => 0x02,  0x40 => 0x00,  0x41 => 0x80,  0x43 => 0x00,
			0x4c => 0x04,  0x4e => 0x00,  0x50 => 0x00,  0x51 => 0x1d,
			0x52 => 0x00,  0x53 => 0x00,  0x58 => 0x20,  0x59 => 0x00,
			0x5a => 0x00,  0x5b => 0x01,
		},
		'0:11.7' => {
			0x64 => 0xe4,  0xe5 => undef, 0xe6 => 0x01,  0x48 => 0x1a,
			0x4e => 0x00,  0x4f => 0x00,  0x50 => 0x00,  0x57 => undef,
			0x61 => 0x00,  0x62 => 0x00,  0x63 => 0x00,
		},
		'0:13.0' => {
			0x74 => undef, 0x75 => undef, 0x76 => undef, 0x77 => undef,
			0x19 => undef, 0x1a => undef, 0x04 => undef, 0x05 => undef,
			0x40 => 0x02,  0x42 => 0x06,
		},
		'0:13.1' => {
			0x74 => undef, 0x75 => undef, 0x76 => undef, 0x77 => undef,
		},
		'80:01.0' => {
			0x10 => undef, 0x11 => undef, 0x12 => undef, 0x13 => undef,
			0x04 => undef, 0x2c => undef, 0x2d => undef, 0x2e => undef,
			0x2f => undef, 0x40 => 0x00,
		},
	};
}

sub init_ports
{
	my $self = shift;

	$self->{_vi} = 'SerialICE v1.5 (Sep  5 2017)';
	$self->{_mb} = 'HP Mini 2133';

	$self->init_cmos;
	$self->init_cmos2;
	$self->init_smbus;
	$self->init_pci;

	$self->{ports} = {
		0x0041 => undef,
		0x0043 => undef,

		sub {
			my $stat = 0xff;

			0x0060 => sub {
				return 0x55 unless @_;
				$stat = shift;
				$stat = 0x10 if $stat == 0xdf;
				$stat = 0x10 if $stat == 0x61;
			},
			0x0061 => sub {
				$stat = 0x00;
			},
			0x0064 => sub {
				return $stat unless @_;
				$stat = shift;
				$stat = 0x18 if $stat == 0xd1;
				$stat = 0x19 if $stat == 0xaa;
				$stat = 0x18 if $stat == 0x60;
			},
		}->(),

		sub {
			my $stat = 0xff;

			0x0070 => undef,
			0x0071 => sub {
				return (defined $self->{ports}{0x0070} ? $self->{cmos}{$self->{ports}{0x0070}} : undef) unless @_;
				$self->{cmos}{$self->{ports}{0x0070}} = shift;
			},
		}->(),

		sub {
			my $stat = 0xff;

			0x0074 => undef,
			0x0075 => sub {
				return (defined $self->{ports}{0x0074} ? $self->{cmos2}{$self->{ports}{0x0074}} : undef) unless @_;
				$self->{cmos2}{$self->{ports}{0x0074}} = shift;
			},
		}->(),

		0x0080 => sub { die 'Done' if @_ and shift eq 0xe6 },
		0x0084 => undef,
		0x008f => undef,
		0x0098 => undef,
		0x0099 => undef,
		0x00e0 => undef,
		0x00e8 => undef,
		0x00ea => undef,
		0x00eb => undef,
		0x00ec => undef,
		0x00ed => undef,
		0x00ee => undef,
		0x00ef => undef,

		sub {
			0x0400 => undef,
			0x0402 => sub {
				$self->{ports}{0x0400} = exists $self->{smbus}{$self->{ports}{0x0404} >> 1} ? 0x42 : 0x44;
			},
			0x0403 => undef,
			0x0404 => undef,
			0x0405 => sub {
				return $self->{smbus}{$self->{ports}{0x0404} >> 1}{$self->{ports}{0x0403}} unless @_;
				$self->{ports}{0x0400} = 0x00;
			},
		}->(),

		0x04d0 => undef,
		0x04d1 => undef,
		0x0500 => undef,
		0x0501 => undef,
		0x0801 => 0x89,
		0x0805 => 0x00,
		0x0822 => 0x00,
		0x0828 => 0x00,
		0x0829 => 0x00,
		0x082d => 0x00,
		0x0840 => 0x00,
		0x0842 => 0x04,
		0x084c => undef,
		0x084d => undef,
		0x084e => undef,
		0x084f => undef,
		0x0852 => 0x00,
		0x0860 => 0x2e,
		0x0864 => 0x00,

		sub {
			my $byte = sub {
				my $a = $self->{ports}{0x0cf8} + shift;
				my $dev = sprintf ('%x:%02x.%d', $self->{ports}{0x0cfa}, $self->{ports}{0x0cf9} >> 3, $self->{ports}{0x0cf9} & 7);
				die unless $self->{pci}{$dev};
				die unless exists $self->{pci}{$dev}->{$a};
				return $self->{pci}{$dev}->{$a}->(@_) if ref $self->{pci}{$dev}->{$a} eq 'CODE';
				return $self->{pci}{$dev}->{$a} unless @_;
				$self->{pci}{$dev}->{$a} = shift;
			};

			0x0cf8 => undef,
			0x0cf9 => undef,
			0x0cfa => undef,
			0x0cfb => undef,
			0x0cfc => sub { $byte->(0, @_) },
			0x0cfd => sub { $byte->(1, @_) },
			0x0cfe => sub { $byte->(2, @_) },
			0x0cff => sub { $byte->(3, @_) },
		}->(),
	};
}

sub init_msr
{
	my $self = shift;

	$self->{msr} = {
		0x000000fe => [ 0x00000000, 0x00000508 ],
		0x00000198 => [ 0x04060810, 0x04000406 ],
		0x00000199 => [ 0x00000000, 0x00000406 ],
		0x0000019d => undef,
		0x000001a0 => [ 0x00000000, 0x00000000 ],
		0x00000200 => undef,
		0x00000201 => undef,
		0x00000201 => undef,
		0x00000202 => undef,
		0x00000202 => undef,
		0x00000203 => undef,
		0x00000203 => undef,
		0x00000204 => undef,
		0x00000204 => undef,
		0x00000205 => undef,
		0x00000205 => undef,
		0x00000206 => undef,
		0x00000206 => undef,
		0x00000207 => undef,
		0x00000208 => undef,
		0x00000209 => undef,
		0x0000020a => undef,
		0x0000020a => undef,
		0x0000020b => undef,
		0x0000020c => undef,
		0x0000020d => undef,
		0x0000020e => undef,
		0x0000020f => undef,
		0x00000250 => undef,
		0x00000258 => undef,
		0x00000259 => undef,
		0x00000268 => undef,
		0x00000269 => undef,
		0x0000026a => undef,
		0x0000026b => undef,
		0x0000026c => undef,
		0x0000026d => undef,
		0x0000026e => undef,
		0x0000026f => undef,
		0x000002ff => [ 0x00000000, 0x00000000 ],
		0x00001107 => [ 0x3c3f8685, 0x9f1f1ac6 ],
		0x00001140 => [ 0x00000800, 0x04000000 ],
		0x00001141 => [ 0x00000000, 0x08000000 ],
		0x00001142 => [ 0x00000000, 0xfeff0323 ],
		0x00001152 => [ 0xe6ecb39f, 0xfbffffff ],
		0x00001154 => [ 0x00000000, 0xfffdffff ],
		0x00001164 => undef,
		0x00001165 => undef,
		0x00001166 => undef,
		0x00001168 => undef,
		0x0000116a => [ 0x00000000, 0x00000003 ],
		0x0000116b => undef,
	};
}

sub ci
{
	my $self = shift;
	my ($eax, $ecx) = @_;

	return (0x00000001, 0x746e6543, 0x736c7561, 0x48727561) if $eax == 0x00000000;
	return (0x000006d0, 0x00000800, 0x00004181, 0xa7c9bbff) if $eax == 0x00000001;
	die;
}

1;
