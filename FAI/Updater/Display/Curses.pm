package FAI::Updater::Display::Curses;
use Curses;
use Curses::UI;
use Curses::UI::Common;
use FAI::Updater;
use base qw(FAI::Updater::Display);
	
sub _init {
	my $self=shift;
	$self->{TITLES}=[qw(unreachable error success running waiting)];
	$self->{COLORS}={ unreachable=>'magenta',
		error=>'red',
		success=>'green',
		running=>'yellow',
		waiting=>'blue'};
	$self->{COLUMN}={
		unreachable=>0,
		error=>1,
		unfinished=>1,
		empty=>0,
		success=>2,
		running=>3,
		started=>3,
		waiting=>4
	};
	$self->SUPER::_init(@_);
	die "I need a WIN" unless $self->{WIN};
	my $hostwidth=POSIX::floor($self->{WIN}->width()/scalar(@{$self->{TITLES}}));
	$self->{WIN}->{-width}=$hostwidth*scalar(@{$self->{TITLES}});
	$self->{WIN}->layout();
	my $sofar=0;
	my $idx=0;
	$self->{COL}=[];
	foreach (@{$self->{TITLES}}) {
		$self->{COL}->[$idx]=$self->{WIN}->add($_,'MyListbox',
			-width=>$hostwidth,
			-x=>$sofar,
			-border=>1,
			-title=>$_,
			-bg=>$self->{COLORS}->{$_},
			-vscrollbar=>1
			);
		$self->{COL}->[$idx]->onChange($self->{SELECT}) if ($self->{SELECT});
		# change default bindings
		$self->{COL}->[$idx]->clear_binding('option-select');
		$self->{COL}->[$idx]->clear_binding('loose-focus');
		$self->{COL}->[$idx]->set_binding('option-select',KEY_ENTER,KEY_SPACE);
		$self->{COL}->[$idx]->set_binding('loose-focus',KEY_RIGHT,CUI_TAB,KEY_BTAB);
		$self->{COL}->[$idx]->set_binding('focus-prev',KEY_LEFT);

		$idx++;$sofar+=$hostwidth;
	}
}

sub set_state {
	my $self=shift;
	my ($host,$state)=(shift,shift);
	my $oldcol=(exists $self->{STATE}->{$host} ? 
		$self->{COLUMN}->{$self->{STATE}->{$host}} :
		-1);
	$self->SUPER::set_state($host,$state);
	my $newcol=$self->{COLUMN}->{$state};
	if ($oldcol!=$newcol) {
		$self->{COL}->[$oldcol]->remove($host) unless ($oldcol<0);
		$self->{COL}->[$newcol]->append($host);
	}
}

1;
