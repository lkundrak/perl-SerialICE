package SerialICE::Server::Emu;

use strict;
use warnings;

use SerialICE::Server;
use base qw/SerialICE::Server/;

sub rm
{
	my $self = shift;
	my ($w, $a) = @_;


	return 0xff unless defined $self->{mem}{$a};
	return $self->{mem}{$a} if $w eq 'b';
	return (($self->rm (b => $a)) | ($self->rm (b => $a + 1) << 8)) if $w eq 'w';
	return (($self->rm (w => $a)) | ($self->rm (w => $a + 1) << 16)) if $w eq 'l';
	die;
}

sub wm
{
	my $self = shift;
	my ($w, $a, $v) = @_;


	return unless exists $self->{mem}{$a};
	return $self->{mem}{$a} = $v if $w eq 'b';
	return $self->wm (b => $a, $v | 0xff), $self->wm (b => $a + 1, ($v >> 8) & 0xff) if $w eq 'w';
	return $self->wm (w => $a, $v | 0xffff), $self->wm (b => $a + 2, ($v >> 8) & 0xffff) if $w eq 'l';
	die;
}

sub ri
{
	my $self = shift;
	my ($w, $a) = @_;

	return (($self->ri (b => $a)) | ($self->ri (b => $a + 1) << 8)) if $w eq 'w';
	return (($self->ri (w => $a)) | ($self->ri (w => $a + 2) << 16)) if $w eq 'l';
	die unless $w eq 'b';

	my $val;
	if (ref $self->{ports}{$a} eq 'CODE') {
		$val = $self->{ports}{$a}->();
	} elsif (defined $self->{ports}{$a}) {
		$val = $self->{ports}{$a};
	}

	die sprintf ('bad ri %04x', $a) unless defined $val;
	return defined $val ? $val : 0xff;
}

sub wi
{
	my $self = shift;
	my ($w, $a, $v) = @_;

	return $self->wi (b => $a, $v & 0xff), $self->wi (b => $a + 1, ($v >> 8) & 0xff) if $w eq 'w';
	return $self->wi (w => $a, $v & 0xffff), $self->wi (w => $a + 2, ($v >> 16) & 0xffff) if $w eq 'l';
	die unless $w eq 'b';

	if (ref $self->{ports}{$a} eq 'CODE') {
		$self->{ports}{$a}->($v);
	} elsif (exists $self->{ports}{$a}) {
		$self->{ports}{$a} = $v;
	}
}

sub rc
{
	my $self = shift;
	my ($a, $k) = @_;

	return @{$self->{msr}{$a}};
}

sub wc
{
	my $self = shift;
	my ($a, $k, $h, $l) = @_;

	die unless exists $self->{msr}{$a};
	$self->{msr}{$a} = [ $h, $l ];
}

sub init_ports
{
	my $self = shift;

	$self->{ports} = {};
	die;
}

sub init_msr
{
	my $self = shift;

	$self->{msr} = {};
	die;
}

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new (@_);

	$self->init_ports;
	$self->init_msr;

	return $self;
}

1;
