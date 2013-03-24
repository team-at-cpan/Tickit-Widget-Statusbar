package Tickit::Widget::Statusbar::Clock;
use strict;
use warnings;
use parent qw(Tickit::Widget::Static);
use POSIX qw(strftime);
use IO::Async::Timer::Periodic;

sub cols { 8 };

sub new {
	my $class = shift;
	my %args = @_;
	my $loop = delete $args{loop};
	my $self = $class->SUPER::new(%args);
	$self->{timer} = IO::Async::Timer::Periodic->new(
		interval => 1.00,
		on_tick => $self->curry::weak::update_time,
	);
	$loop->add($self->{timer});
	$self
}

sub window_gained {
	my $self = shift;
	$self->SUPER::window_gained(@_);
	$self->timer->start if $self->timer;
}

sub timer { shift->{timer} }

sub window_lost {
	my $self = shift;
	$self->SUPER::window_lost(@_);
	$self->timer->stop if $self->timer;
}

sub time_format { '%H:%M:%S' }

sub update_time {
	my $self = shift;
	$self->set_text(strftime $self->time_format, localtime);
}

1;
