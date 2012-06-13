package Tickit::Widget::Statusbar;
# ABSTRACT: Basic status bar definition
use strict;
use warnings;
use parent qw(Tickit::Widget);

our $VERSION = 0.001;

use POSIX qw(strftime);
use IO::Async::Timer::Periodic;
use Scalar::Util ();

=head1 NAME

Tickit::Widget::Statusbar

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

sub lines { 1 }
sub cols  { 1 }

sub new {
	my $class = shift;
	my %args = @_;
	my $loop = delete $args{loop} or die 'no IO::Async::Loop provided';
	my $self = $class->SUPER::new(%args);
	$self->{status_text} = "";
	Scalar::Util::weaken($self->{loop} = $loop);

	$self->{timer} = IO::Async::Timer::Periodic->new(
		interval => 1.00,
		on_tick => $self->sap(sub { my $self = shift; $self->redraw; })
	);
	$loop->add($self->{timer});
	return $self;
}

sub render {
	my $self = shift;

	my $win = $self->window or return;
	$win->goto(0, 0);
	my $blank = ($win->cols - 8) - length($self->{status_text});
	$win->print($self->{status_text} . (' ' x $blank) . strftime("%H:%M:%S", localtime), bg => 4, fg => 3, b => 1);
}

sub update_status {
	my $self = shift;
	$self->{status_text} = shift;
	$self->resized;
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
sub sap { my ($self, $code) = @_; Scalar::Util::weaken $self; sub { $code->($self, @_) } }

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

