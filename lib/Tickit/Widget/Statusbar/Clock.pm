package Tickit::Widget::Statusbar::Clock;
use strict;
use warnings;
use parent qw(Tickit::Widget);

=head1 NAME

Tickit::Widget::Statusbar::Clock - a simple clock implementation

=head1 DESCRIPTION

Integrated as part of the default status bar.

=cut

use constant CLEAR_BEFORE_RENDER => 0;

use POSIX qw(strftime floor);
use IO::Async::Timer::Periodic;
use Time::HiRes ();

sub cols { 8 }

sub lines { 1 }

sub render {
	my $self = shift;
	my %args = @_;
	my $win = $self->window or return;

	$win->goto(0, 0);
	$win->print(strftime $self->time_format, localtime);
}

=head2 new

Takes the following named parameters:

=over 4

=item * loop - the L<IO::Async::Loop> for attaching the timer

=back

Returns $self.

=cut

sub new {
	my $class = shift;
	my %args = @_;
	my $loop = delete $args{loop} or die "No loop provided";
	my $self = $class->SUPER::new;
	my $now = Time::HiRes::time;
	$self->{timer} = IO::Async::Timer::Periodic->new(
		interval => 1.00,
		reschedule => 'skip',
		first_interval => 0.01 + ($now - floor($now)),
		on_tick => $self->curry::weak::redraw,
	);
	$loop->add($self->{timer});
	$self
}

=head2 window_gained

Starts the timer when we get a window.

Returns $self.

=cut

sub window_gained {
	my $self = shift;
	$self->SUPER::window_gained(@_);
	if(my $timer = $self->timer) {
		$timer->stop if $timer->is_running;
		my $now = Time::HiRes::time;
		$timer->{first_interval} = 0.01 + ($now - floor($now));
		$timer->start;
	}
}

=head2 timer

Accessor for the L<IO::Async::Timer::Periodic> object.

=cut

sub timer { shift->{timer} }

=head2 window_lost

Stop the timer if we lose our window.

=cut

sub window_lost {
	my $self = shift;
	$self->SUPER::window_lost(@_);
	$self->timer->stop if $self->timer && $self->timer->is_running;
}

=head2 time_format

Our format for displaying current time.

=cut

sub time_format { '%H:%M:%S' }

1;
