package FAI::Updater::Display::Logfile;
use strict;
use warnings;
use FAI::Updater;
use POSIX qw(strftime);
use base qw(FAI::Updater::Display);

sub _init {
  my $self=shift;
  $self->SUPER::_init(@_);
  die "I need a FILENAME" unless $self->{FILENAME};
  open $self->{FH},">".$self->{FILENAME};
  $self->{FH}->autoflush() if $self->{AUTOFLUSH};
}

sub DESTROY {
  my $self=shift;
  close $self->{FH};
}

sub set_state {
  my ($self,$host,$state)=(shift,shift,shift);
  my $oldstate=$self->{STATE}->{$host};
  $self->SUPER::set_state($host,$state);
  unless (defined $oldstate and ($state eq $oldstate)) {
    print {$self->{FH}} "".strftime("%H:%M:%S",localtime)." $host ($state)\n";
  }
}

1;
