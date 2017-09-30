package SerialICE::Server::Replay;

use strict;
use warnings;

use SerialICE::Server;
use base qw/SerialICE::Server/;

*SerialICE::Server::Replay::addr = *SerialICE::Server::addr;

sub nextline
{
	my $self = shift;
	my $capture = $self->{capture};

	$self->{_line} = $capture ? <$capture> : <>;
	exit unless defined $self->{_line};
	$_ = $self->{_line};
}

sub run
{
	my $self = shift;
	my $capture = $self->{capture};

	$self->{_vi} = 'SerialICE v1.5 (unknown)';
	$self->{_mb} = 'Unknown Board';

	do {
		$self->nextline;
		/SerialICE: Version\.*: (.*)/ and $self->{_vi} = $1;
		/SerialICE: Mainboard\.*: (.*)/ and $self->{_mb} = $1;
	} while ($self->{_line} !~ /^[0-9a-f]{4}\.[0-9a-f]{4}/);

	return $self->SUPER::run (@_);
}

sub nextcommand
{
	my $self = shift;
	my ($ex_kind, $ex_op, $ex_dir, $ex_val) = @_;
	my ($kind, $op, $dir, $val);

	while (1) {
		if ($self->{_line} =~ /^\S{4}\.\S{4}\s+.H..\s+\S+\s+([^:]+):\s+(.*) (\S\S) (\S+)$/) {
			($kind, $op, $dir, $val) = ($1, $2, $3, $4);
			last;
		}
		$self->nextline;
	}

	if ($ex_kind ne $kind or $ex_op ne $op or $ex_dir ne $dir) {
		warn "$self->{_line}";
		warn "{$ex_kind} {$ex_op} {$ex_dir} != {$kind} {$op} {$dir} {$val}";
		die;
	}

	warn "[$ex_val] $self->{_line}" if defined $ex_val and $ex_val ne $val;
	$self->nextline;
	return $val;
}

sub rm
{
	my $self = shift;
	my ($w, $a) = @_;

	my $val = $self->nextcommand ('MEM', sprintf ('read%s %08x', $w, $a), '=>');
	return $self->SUPER::rm (@_) unless defined $val;
	return hex $val;
}

sub wm
{
	my $self = shift;
	my ($w, $a, $v) = @_;

	$self->nextcommand ('MEM', sprintf ('write%s %08x', $w, $a), '<=', addr ($w, $v));
}

sub ri
{
	my $self = shift;
	my ($w, $a) = @_;

	my $val = $self->nextcommand ('IO', sprintf ('in%s %04x', $w, $a), '=>');
	return $self->SUPER::ri (@_) unless defined $val;
	return hex $val;
}

sub wi
{
	my $self = shift;
	my ($w, $a, $v) = @_;

	$self->nextcommand ('IO', sprintf ('out%s %04x', $w, $a), '<=', addr ($w, $v));
}

sub ci
{
	my $self = shift;
	my ($eax, $ecx) = @_;

	my $val = $self->nextcommand ('CPUID', sprintf ('eax: %08x; ecx: %08x', $eax, $ecx), '=>');
	return $self->SUPER::ci (@_) unless defined $val;
	$val =~ /^([0-9a-f]{8})\.([0-9a-f]{8})\.([0-9a-f]{8})\.([0-9a-f]{8})$/ or die;
	return (hex $1, hex $2, hex $3, hex $4);
}

sub rc
{
	my $self = shift;
	my ($k, $v) = @_;

	my $val = $self->nextcommand ('CPU MSR', sprintf ('[%08x]', $k), '=>');
	return $self->SUPER::rc (@_) unless defined $val;
	$val =~ /^([0-9a-f]{8})\.([0-9a-f]{8})$/ or die;
	return (hex $1, hex $2);
}

sub wc
{
	my $self = shift;
	my ($k, $v, $h, $l) = @_;

	$self->nextcommand ('CPU MSR', sprintf ('[%08x]', $k), '<=', sprintf ('%08x.%08x', $h, $l));
}

1;
