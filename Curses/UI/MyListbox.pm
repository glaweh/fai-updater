package Curses::UI::MyListbox;
use base qw(Curses::UI::Listbox);
sub append {
	my $self = shift;
	my $value = shift;
	push @{$self->{-values}},$value;
	$self->intellidraw();
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
	$self->intellidraw();
}

return 1;
