package Tickit::Widget::Statusbar;
# ABSTRACT: Basic status bar definition
use strict;
use warnings;
use parent qw(Tickit::Widget::HBox);
use curry::weak;
use Tickit::Widget::Statusbar::Clock;
use Tickit::Style;

our $VERSION = 0.001;

=head1 NAME

Tickit::Widget::Statusbar - provides a simple status bar implementation

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

style_definition base =>
	fg => 'hi-yellow',
	bg => 'blue';

style_definition base =>
   spacing => 0;

style_reshape_keys qw( spacing );

use Scalar::Util ();

=head1 METHODS

=cut

sub lines { 1 }
sub cols  { 1 }

=head2 new



=cut

sub new {
	my $class = shift;
	my %args = @_;

	my $status = delete $args{status};
	my $self = $class->SUPER::new(%args);
	$self->add($self->{status} = $status, expand => 1);
	$self->add(
		$self->{clock} = Tickit::Widget::Statusbar::Clock->new,
	);
	return $self;
}


sub render_to_rb {
	my ($self, $rb, $rect) = @_;
	$rb->text_at(0, 0, $self->status, $self->widget_pen);
}

=head2 update_status

Set current status. Takes a single parameter - the string to set the status
to.

Returns $self.

=cut

sub update_status {
	my $self = shift;
	$self->{status}->set_text(shift // '');
}

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

