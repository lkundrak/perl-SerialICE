package SerialICE::Client::Replay;

use SerialICE::Client;
use base qw/SerialICE::Client/;

use strict;
use warnings;

our $dispatch = {
	'IO' => {
		'=>' => sub {
			my $self = shift;
			my ($d, $v) = @_;

			$d =~ /([wlb]) ([^ ]*)$/ or die;
			$self->ri ($1 => hex $2);
		},
		'<=' => sub {
			my $self = shift;
			my ($d, $v) = @_;

			$d =~ /([wlb]) ([^ ]*)$/ or die;
			$self->wi ($1 => hex $2, hex $v);
		},
	},
	'CPUID' => {
		'=>' => sub {
			my $self = shift;

			$_[0] =~ /eax: (\S+); ecx: (\S+)/ or die;
			$self->ci (hex $1, hex $2),
		},
	},
	'CPU MSR' => {
		'=>' => sub {
			my $self = shift;

			$_[0] =~ /\[(\S+)]/ or die;
			$self->rc (hex $1)
		},
		'<=' => sub {
			my $self = shift;
			my ($d, $v) = @_;

			"$d $v" =~ /\[(\S+)] (\S{8})\.(\S{8})/ or die;
			$self->wc (hex $1, (hex $2) << 32 | hex $3);
		},
	},
	'MEM' => {
		'=>' => sub {
			my $self = shift;
			my ($d, $v) = @_;

			$d =~ /([wlb]) ([^ ]*)$/ or die;
			$self->rm ($1 => hex $2);
		},
		'<=' => sub {
			my $self = shift;
			my ($d, $v) = @_;

			$d =~ /([wlb]) ([^ ]*)$/ or die;
			$self->wm ($1 => hex $2, hex $v);
		},
	},
};

sub run
{
	my $self = shift;
	my $capture = $self->{capture};

	# Replay
	while ($_ = ($capture ? <$capture> : <>)) {
		next unless (/^\S{4}\.\S{4}\s+.H..\s+\S+\s+([^:]+):\s+(.*) (\S\S) (\S+)$/);
		$dispatch->{$1}{$3}->($self, $2, $4);
	}
}
