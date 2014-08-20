#!/usr/bin/env perl
use strict;
use warnings;
use Tickit::Async;
use IO::Async::Loop;
use Tickit::Widget::Statusbar;
use Tickit::Widget::Static;
use Tickit::Widget::VBox;
my $loop = IO::Async::Loop->new;
$loop->add(my $tickit = Tickit::Async->new);
my $vbox = Tickit::Widget::VBox->new;
$vbox->add(Tickit::Widget::Static->new(text => 'status bar demo'), expand => 1);
$vbox->add(my $status = Tickit::Widget::Statusbar->new);
$status->update_status('testing status line');
$tickit->timer(
	after => 0.5,
	sub {
		$status->update_status(
			String::Tagged->new(
				"Some tagged text using String::Tagged"
			)->apply_tag(0, 4, fg => 'green')
			 ->apply_tag(5, 6, fg => 'hi-green')
			 ->apply_tag(12, 4, fg => 'hi-red')
			 ->apply_tag(17, 5, fg => 'hi-blue')
		)
	}
);
$tickit->set_root_widget($vbox);
$tickit->run;

