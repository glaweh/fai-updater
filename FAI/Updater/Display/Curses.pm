package FAI::Updater::Display::Curses;
use Curses::UI;
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
			-bg=>$self->{COLORS}->{$_}
			);
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
