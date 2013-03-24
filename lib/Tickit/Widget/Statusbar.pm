package Tickit::Widget::Statusbar;
# ABSTRACT: Basic status bar definition
use strict;
use warnings;
use parent qw(Tickit::Widget::HBox);
use curry::weak;
use Tickit::Widget::Statusbar::Clock;

our $VERSION = 0.001;

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
	my $pen = delete $args{pen} || Tickit::Pen->new(bg => 4, fg => 3, b => 1);
	my $status = delete $args{status};
	$status = Tickit::Widget::Static->new(align => 'left', valign => 'middle', text => $status // '') unless ref $status;
	my $self = $class->SUPER::new(%args);
	$self->set_pen($pen);
	$self->add($self->{status} = $status, expand => 1);
	$self->add($self->{clock} = Tickit::Widget::Statusbar::Clock->new(loop => $loop));
	$self->{clock}->update_time;
	return $self;
}

sub update_status {
	my $self = shift;
	$self->{status}->set_text(shift);
}

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

