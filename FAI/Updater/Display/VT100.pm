package FAI::Updater::Display::VT100;
use strict;
use warnings;
use FAI::Updater;
use base qw(FAI::Updater::Display);

my $CSI=chr(27) . "[";
my $DEFCOLOR=$CSI."0m";

my %scolor = (
  waiting => $CSI."34;1m", # blue
  started => $CSI."33;1m", # yellow
  running => $CSI."33;7m", # inverse yellow
  success => $CSI."32;1m", # green
  error   => $CSI."31;7m", # inverse red
  unfinished => $CSI."31;4m", # underlined red
  empty   => $CSI."31m"    # red
  );
  
sub _init {
  my $self=shift;
  $self->{HIDE}={};
  $self->{TITLE}="define a real title";
  $self->SUPER::_init(@_);
  $self->{ENABLED}=0;
}

sub set_state {
  my $self=shift;
  $self->SUPER::set_state(@_);
  my ($host,$state)=(shift,shift);
  if ($self->{ENABLED}) {
    $self->_show()
  } elsif ($state ne 'waiting') {
    $self->{ENABLED}=1;
    $self->{DEBUG} or print $CSI."f$CSI"."0J";
    print $self->{TITLE}."\nStates: ";
    foreach (@FAI::Updater::states) {
      print "".(defined $scolor{$_} ? $scolor{$_} : '' )."$_$DEFCOLOR ";
    }
    print "\n";
  }
}

sub _show {
  my $self=shift;
  # set the cursor to 3,1 and clear everything below
  my $result;
  $self->{DEBUG} or $result=$CSI . "3f$CSI" . "0J" ;
  foreach (sort keys %{$self->{STATE}}) {
    # the current status
    my $s=$self->{STATE}->{$_};
    # allow ignoring hosts in some states
    next if exists $self->{HIDE}->{$s};
    # colorize hostname if there's a color corresponding the state
    $result .= (defined $scolor{$s} ? $scolor{$s} : '' ) . "$_$DEFCOLOR\n";
  }
  # print everything in one go to keep the flicker low
  print $result;
}

sub hide_states {
  my $self=shift;
  $self->{HIDE}={};
  map { $self->{HIDE}->{$_}=1 } @_;
}

sub debug {
  my $self=shift;
  return $self->{DEBUG} unless my $debug=shift;
  $self->{DEBUG}=$debug;
}

