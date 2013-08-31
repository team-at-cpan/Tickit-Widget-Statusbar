package Tickit::Widget::Statusbar;
# ABSTRACT: Basic status bar definition
use strict;
use warnings;
use parent qw(Tickit::ContainerWidget);
our $VERSION = 0.001;

=head1 NAME

Tickit::Widget::Statusbar - provides a simple status bar implementation

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use curry::weak;
use Tickit::Widget::Statusbar::Clock;
use Tickit::Widget::Statusbar::CPU;
use Tickit::Widget::Statusbar::Memory;
use Tickit::Style;
use List::Util qw(max);
use Tickit::Utils qw(substrwidth textwidth);
use Scalar::Util ();

use constant WIDGET_PEN_FROM_STYLE => 1;
use constant CAN_FOCUS => 0;

BEGIN {
	style_definition base =>
		fg => 'white',
		bg => 232,
		spacing => 1;

	style_reshape_keys qw(spacing);
}

=head1 METHODS

=cut

sub lines { 1 }
sub cols  { 1 }

sub children {
	@{shift->{children}};
}

=head2 new



=cut

sub new {
	my $class = shift;
	my %args = @_;

	my $status = delete($args{status}) // '';
	my $self = $class->SUPER::new(%args);
	$self->{children} = [];
	$self->{status} = $status;
	
	$self->add(
		$self->{mem} = Tickit::Widget::Statusbar::Memory->new or die "no widget?"
	);
	$self->add(
		$self->{cpu} = Tickit::Widget::Statusbar::CPU->new or die "no widget?"
	);
	$self->add(
		$self->{clock} = Tickit::Widget::Statusbar::Clock->new or die "no clock?",
	);
	return $self;
}

sub add {
	my $self = shift;
	my $w = shift;
	push @{$self->{children}}, $w;
	$self->SUPER::add($w, @_);
}
sub children_changed {
	my $self = shift;
	return unless my $win = $self->window;
	my $x = $win->cols;
	for my $child (reverse $self->children) {
		my $sub = $win->make_sub(
			0, $x - $child->cols, 1, $child->cols
		);
		$child->set_window($sub);
		$x -= $child->cols + $self->get_style_values('spacing');
	}
}

sub window_gained {
	my $self = shift;
	$self->SUPER::window_gained(@_);
	$self->children_changed;
}

sub status { shift->{status} }

sub render_to_rb {
	my ($self, $rb, $rect) = @_;
	# textwidth $self->status
	my $txt = substrwidth $self->status, $rect->left, $rect->cols;
	$rb->text_at($rect->top, $rect->left, $txt, $self->get_style_pen);
	# $rb->erase_at($rect->top, $rect->left + textwidth($txt), $rect->cols - textwidth($txt), $self->get_style_pen);
	$rb->text_at($rect->top, $rect->left + textwidth($txt), ' ' x ($rect->cols - textwidth($txt)));
}

=head2 update_status

Set current status. Takes a single parameter - the string to set the status
to.

Returns $self.

=cut

sub update_status {
	my $self = shift;
	my $old_status = $self->{status};
	$self->{status} = shift // '';
	$self->window->expose(Tickit::Rect->new(
		left => 0,
		top => 0, 
		lines => 1,
		cols => max(length $old_status, length $self->{status})
	)) if $self->window;
}

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2011. Licensed under the same terms as Perl itself.

