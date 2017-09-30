package SerialICE::Server;

use strict;
use warnings;

sub new
{
	my $class = shift;
	my $self = shift;

	$self->{port}->autoflush (1) if $self->{port};
        $self->{_vi} = 'SerialICE v1.5 (unknown)';
        $self->{_mb} = 'Unknown Board';

	return bless $self, $class;
}

our %commands = (
	vi => sub {
		my $self = shift;

		return $self->vi ();
	},
	mb => sub {
		my $self = shift;

		return $self->mb ();
	},
	rm => sub {
		my $self = shift;

		return undef unless /(........)(..)/;
		return 'Error' unless /([0-9a-f]{8})\.([wlb])/;
		return addr ($2 => $self->rm ($2 => hex $1));
		return 'Good';
	},
	wm => sub {
		my $self = shift;

		return undef unless /^(........)(.b.)(..)/
			or /^(........)(.w.)(....)/
			or /(........)(...)(........)/;
		return 'Error' unless /([0-9a-f]{8})\.([wlb])=([0-9a-f]*)$/;
		$self->wm ($2 => hex $1, hex $3);
		return '';
	},
	ri => sub {
		my $self = shift;

		return undef unless /(....)(..)/;
		return 'Error' unless /([0-9a-f]{4})\.([wlb])/;
		return addr ($2 => $self->ri ($2 => hex $1));
	},
	wi => sub {
		my $self = shift;

		return undef unless /^(....)(.b.)(..)/
			or /^(....)(.w.)(....)/
			or /(....)(...)(........)/;
		return 'Error' unless /([0-9a-f]{4})\.([wlb])=([0-9a-f]*)$/;
		$self->wi ($2 => hex $1, hex $3);
		return '';
	},
	ci => sub {
		my $self = shift;

		return undef unless /(........)(.)(........)/;
		return 'Error' unless /([0-9a-f]{8})\.([0-9a-f]{8})/;
		return sprintf '%08x.%08x.%08x.%08x', $self->ci (hex $1, hex $2);
	},
	rc => sub {
		my $self = shift;

		return undef unless /(........)(.)(........)/;
		return 'Error' unless /([0-9a-f]{8})\.([0-9a-f]{8})/;
		return sprintf '%08x.%08x', $self->rc (hex $1, hex $2);
	},
	wc => sub {
		my $self = shift;

		return undef unless /(........)(.)(........)(.)(........)(.)(........)/;
		return 'Error' unless /([0-9a-f]{8})\.([0-9a-f]{8})=([0-9a-f]{8})\.([0-9a-f]{8})/;
		$self->wc (hex $1, hex $2, hex $3, hex $4);
		return '';
	},
	xx => sub {
		my $self = shift;

		exit;
	},
);

sub addr
{
	my ($w, $a) = @_;

	return sprintf '%08x', $a if $w eq 'l';
	return sprintf '%04x', $a if $w eq 'w';
	return sprintf '%02x', $a if $w eq 'b';
	die;
}

sub vi
{
	my $self = shift;

	return $self->{_vi}."\n";
}

sub mb
{
	my $self = shift;

	return sprintf '%-31s', $self->{_mb};
}

sub rm
{
	my $self = shift;
	my ($w, $a) = @_;

	return 0xffffffff if $w eq 'l';
	return 0xffff if $w eq 'w';
	return 0xff if $w eq 'b';
	die;
}

sub wm
{
	my $self = shift;
	my ($w, $a, $v) = @_;

	return if $w eq 'l';
	return if $w eq 'w';
	return if $w eq 'b';
	die;
}

sub ri
{
	my $self = shift;
	my ($w, $a) = @_;

	return 0xffffffff if $w eq 'l';
	return 0xffff if $w eq 'w';
	return 0xff if $w eq 'b';
	die;
}

sub wi
{
	my $self = shift;
	my ($w, $a, $v) = @_;

	return if $w eq 'l';
	return if $w eq 'w';
	return if $w eq 'b';
	die;
}

sub ci
{
	my $self = shift;
	my ($eax, $ecx) = @_;

	return (0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff);
}

sub rc
{
	my $self = shift;
	my ($k, $v) = @_;

	return (0xffffffff, 0xffffffff);
}

sub wc
{
	my $self = shift;
	my ($k, $v, $h, $l) = @_;
}

sub readc
{
	my $self = shift;
	my $str;

	sysread $self->{port}, $str, 1 or die "read: $!";
	$self->print ("$str") if $self->{echo};

	return $str;
}

sub print
{
	my $self = shift;

	$self->{port}->print (@_);
	print @_ if $self->{trace};
}

sub run
{
        my $self = shift;
        my $line = '';

	$self->print ($self->vi."\r\n".$self->mb);
        while (1) {
		$self->print ("\r\n> ") if $line eq '';

                my $c = $self->readc ();
                $line .= $c;

		if ($line =~ /^[\r\n@]/) {
			$line = '';
		} elsif ($line =~ /^\*/s) {
			if ($line =~ /[\r\n]$/s) {
				$line = '';
			} elsif ($line =~ /^\*(..)(.*)/s) {
				if ($commands{$1}) {
					local $_ = $2;
					my $response = eval { $commands{$1}->($self) };
					$response = "Error: $@" if $@;
					$self->print ("\r\n$response") if $response;
					return if $@;
					$line = '' if defined $response;
				} else {
					$self->print ("\r\nBad command: '$1'");
					$line = '';
				}
				#$line = $self->cmd ($line);
			}
		} else {
			$self->print ("\r\nExpected a '*'");
			$line = '';
		}
        }
}

1;
