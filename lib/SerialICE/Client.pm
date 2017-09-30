package SerialICE::Client;

use strict;
use warnings;

sub new
{
	my $class = shift;
	my $self = shift;

	$self->{port}->autoflush (1) if $self->{port};
	return bless $self, $class;
}

# Read a number of characters
sub readc
{
	my $self = shift;
	my $str;
	my $rin = '';

	vec ($rin, fileno ($self->{port}), 1) = 1;

	my ($nfound, $timeleft) = select (my $rout = $rin, undef, undef, 1);
	return '' unless $nfound;

	sysread $self->{port}, $str, 1 or die "read: $!";

	print "$str" if $self->{trace};
	return $str;
}

# Read until shell or timeout
sub readall
{
	my $self = shift;
	my $line = '';

	while (1) {
		my $c = $self->readc ();
		$line .= $c;
		return $1 if $line =~ /(.*)\r\n> $/s;
		return undef if $c eq '';
	}
}

# Resynchronize until you get shell
sub shell
{
	my $self = shift;

	warn 'Resynchronizing...';
	local $self->{trace} = 0;
	syswrite $self->{port}, ("\n" x 10);
	return if not $self->{port};
	while ($self->readall ()) {};
}

# Write command
sub writec
{
	my $self = shift;
	my $c = shift;

	$SerialICE::cmd++;

	print "Command: '$c'\n" if $self->{trace};
	return if not $self->{port};


AGAIN:
	foreach my $ch (split /.\K/, $c) {
		syswrite $self->{port}, $ch;
		my $rb = $self->readc ();
		if ($rb ne $ch) {
			# Bad command echo
			$self->shell ();
			goto AGAIN;
		}
	}

	my $ret = $self->readall ();
	unless (defined $ret) {
		# Did not read up to shell
		$self->shell ();
		goto AGAIN;
	}

	return $ret;
}

# Version info
sub vi
{
	my $self = shift;

	$_ = $self->writec ("*vi");
	return if not $self->{port};
	/\r\n(.*\S)/ or die;
	return $1;
}

# Board model
sub mb
{
	my $self = shift;

	$_ = $self->writec ("*mb");
	return if not $self->{port};
	/\r\n(.*\S)/ or die;
	return $1;
}

# Format memory address
sub addr
{
	my $self = shift;
	my ($aw, $width, $addr, $val) = @_;

	my %conv = (b => '%02x', w => '%04x', l => '%08x');
	sprintf ($aw.'.%s%s', $addr, $width,
		defined $val ? sprintf ('='.$conv{$width}, $val) : '');
}

# Read memory
sub rm
{
	my $self = shift;

	$_ = $self->writec ('*rm'.$self->addr ('%08x', @_));
	return 0xffffffff if not $self->{port};
	/\r\n(.+)/ or die;
	return hex $1;
}

# Read memory
sub wm
{
	my $self = shift;

	$self->writec ('*wm'.$self->addr ('%08x', @_));
}

# Read io
sub ri
{
	my $self = shift;

	$_ = $self->writec ('*ri'.$self->addr ('%04x', @_));
	return 0xffffffff if not $self->{port};
	/\r\n(.+)/ or die;
	return hex $1;
}

# Write io
sub wi
{
	my $self = shift;

	$self->writec ('*wi'.$self->addr ('%04x', @_));
}

# Read MSR
sub rc
{
	my $self = shift;
	my ($reg, $key) = @_;

	$_ = $self->writec (sprintf '*rc%08x.%08x', $reg, $key // 0);
	return 0xffffffff if not $self->{port};
	/\r\n([^\.]+)\.([^\.]+)/ or die;
	return (hex $1) << 32 | hex $2;
}

# Write MSR
sub wc
{
	my $self = shift;
	my ($reg, $val, $key) = @_;

	$self->writec (sprintf '*wc%08x.%08x=%08x.%08x', $reg, $key // 0,
		$val >> 32, $val & 0xffffffff);
}

# CPUID
sub ci
{
	my $self = shift;
	my ($eax, $ecx) = @_;

	$_ = $self->writec (sprintf '*ci%08x.%08x', $eax, $ecx);
	return if not $self->{port};
	/\r\n([^\.]+)\.([^\.]+)\.([^\.]+)\.([^\.]+)/ or die;
	return (hex $1, hex $2, hex $3, hex $4);
}

1;
