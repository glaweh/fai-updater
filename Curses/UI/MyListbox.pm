package Curses::UI::MyListbox;
use Curses;
use base qw(Curses::UI::Listbox);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->set_routine('focus-prev',\&focus_prev);
}

sub focus_prev {
	my $self = shift;
	$self->loose_focus(KEY_BTAB);
}

sub append {
	my $self = shift;
	my $value = shift;
	push @{$self->{-values}},$value;
	$self->draw();
}

sub remove {
	my $self = shift;
	my $value = shift;
	foreach (0 .. @{$self->{-values}}) {
 		if (defined $self->{-values}[$_] and $self->{-values}[$_] eq $value) {
			splice(@{$self->{-values}},$_,1);
			$self->{-ypos}-- if ($_<$self->{-ypos});
			$self->{-selected}-- if (defined $self->{-selected} and ($_<$self->{-selected}));
		}
	}
	$self->draw();
}

return 1;
