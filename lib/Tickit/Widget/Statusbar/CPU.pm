package Tickit::Widget::Statusbar::CPU;

use strict;
use warnings;

use parent qw(Tickit::Widget);

=head1 NAME

Tickit::Widget::Statusbar::CPU - CPU usage

=head1 DESCRIPTION

Integrated as part of the default status bar.

=cut

use constant CLEAR_BEFORE_RENDER => 0;
use constant WIDGET_PEN_FROM_STYLE => 1;
use constant CAN_FOCUS => 0;

use POSIX qw(strftime floor);
use Time::HiRes ();
use List::Util qw(min max sum);
use curry;
use BSD::Resource qw(getrusage);

sub cols { 4 }

sub lines { 1 }

sub usage {
    my ($self) = @_;
    my $now = Time::HiRes::time();
    my $usage = 0.0;
    my $cpu = getrusage();
    if(defined $self->{start}) {
        my $elapsed = $now - $self->{start};
        $usage = min 100, max 0, 100 * (
            ($cpu->stime - $self->{stime}) + ($cpu->utime - $self->{utime})
        ) / ($elapsed || -1);
    } else {
        $self->{start} = $now;
        $self->{utime} = $cpu->utime;
        $self->{stime} = $cpu->stime;
    }
    $self->{last_update} = $now;
    return $usage;
}

sub render_to_rb {
	my $self = shift;
	my $rb = shift;

	$rb->goto(0, 0);
	my $cpu = $self->usage;
	my $pen = $self->{cpu_pen}[int $cpu] ||= Tickit::Pen->new(
		fg => $self->colour(
			$cpu / 100.0,
			(100 - $cpu) / 100.0,
			0
		),
		b => 1,
	);
	$rb->text(sprintf('%3d%%', $cpu), $pen);
}

=head2 window_gained

Starts the timer when we get a window.

Returns $self.

=cut

sub window_gained {
	my $self = shift;
	$self->SUPER::window_gained(@_);
	$self->update;
}

sub update {
	my $self = shift;
	return unless my $win = $self->window;
	my $now = Time::HiRes::time;
	$self->redraw;
	$win->tickit->timer(
		after => (1.902 - ($now - floor($now))),
		$self->curry::update
	);
}

sub _zero_offset { 16 }
sub _green_offset { 6 }
sub _red_offset { 36 }
sub _blue_offset { 1 }
sub _green_max { 5 }
sub _red_max { 4 }
sub _blue_max { 5 }

my %base16 = (
	'800' => 1,
	'080' => 2,
	'880' => 3,
	'008' => 4,
	'808' => 5,
	'088' => 6,
	'ccc' => 7, # one of these is not like the others...
	'888' => 8,
	'f00' => 9,
	'0f0' => 10,
	'ff0' => 11,
	'00f' => 12,
	'f0f' => 13,
	'0ff' => 14,
	'fff' => 15,
);

sub colour {
	my $self = shift;
	my @max = (4, 5, 5);

	# These should be usable as offsets into the colour cube
	my @scaled = map floor(0.5 + ($_[$_] * $max[$_])), 0..$#_;

	# This is a stepped value taking into account the resolution in the colour cube
	my @ratio = map floor(0.5 + $_[$_] * $max[$_]), 0..$#_;

	# and an 'RGB' version (single digit hex for each component)
	my $as_hex = sprintf '%x%x%x', map floor(0.5 + 15 * $_), @_;

	# If we think it's one of the greys, use the 12-point scale there directly
	return 232 + floor(0.5 + ($_[1] * 12)) if $as_hex =~ /^(.)\1\1/ && $as_hex ne '000' && $as_hex ne '888' && $as_hex ne 'fff';

	# One of the base 16 colours? Have some of that
	return $base16{$as_hex} if exists $base16{$as_hex};

	# Try to guess one from the remaining 216-ish entries in the cube
	return sum $self->_zero_offset, map $self->${\"_${_}_offset"} * shift(@scaled), qw(red green blue);
}

1;
