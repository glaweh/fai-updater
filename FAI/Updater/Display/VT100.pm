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
}

sub enable {
  my $self=shift;
  #set the cursor to 1,1 and clear everything below 
  $self->{DEBUG} or print $CSI."f$CSI"."0J" ;
  print $self->{TITLE}."\nStates: ";
  # color legend
  foreach (@FAI::Updater::states) {
    print "" . (defined $scolor{$_} ? $scolor{$_} : '' ) . "$_$DEFCOLOR ";
  }
  print "\n";
  $self->SUPER::enable;
  $self->show();
}

sub set_state {
  my $self=shift;
  $self->SUPER::set_state(@_);
  $self->show() if ($self->{ENABLED});
}

sub show {
  my $self=shift;
  # set the cursor to 3,1 and clear everything below
  my $result;
  $self->{DEBUG} or $result=$CSI . "3f$CSI" . "0J" ;
  foreach (sort keys %{$self->{STATUS}}) {
    # the current status
    my $s=$self->{STATUS}->{$_};
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

