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
		splice(@{$self->{-values}},$_,1) if (defined $self->{-values}[$_] and $self->{-values}[$_] eq $value);
	}
	$self->intellidraw();
}

return 1;
