package FAI::Updater;
use strict;
use POSIX qw(:sys_wait_h strftime);
use IPC::Open2;
our @states = qw(unreachable error unfinished empty success running started waiting);
#   unreachable - host didn't ping
#   error       - an error occured, hav a look at the logfiles
#   unfinished  - update didn't run to the end (?)
#   empty       - logfile is empty
#   success     - updated without errors
#   running     - update is running
#   started     - update has been started
#   waiting     - update not yet started

sub new {
  my ($class,$display,$logdir) = (shift,shift,shift);
  my $self = {};
  die "I need a DISPLAY" unless $self->{DISPLAY}=$display;
  $self->{LOGDIR}=(defined $logdir ? $logdir : "/var/log/fai-updater/" . strftime("%Y-%m-%d_%H-%M-%S", localtime));
  die "logdir".$self->{LOGDIR}." already exists !" if -d $self->{LOGDIR};
  die "can't create logdir ".$self->{LOGDIR} unless mkdir $self->{LOGDIR};
  $self->{HOSTPID}={};
  $self->{DRYRUN}=0;
  $self->{TO_DO}=();
  $self->{MAX_SIMULTANOUS}=4;
  $self->{PING}=1;
  bless($self,$class);
  return $self;
}

sub dryrun {
  my $self=shift;
  return $self->{DRYRUN} unless my $mode=shift;
  $self->{DRYRUN} = $mode;
}

sub start_one {
  my ($self,$host)=(shift,shift);
  my $command = ($self->{DRYRUN} ? "libexec/dryrun" : "libexec/faiupdate" );
  
  if ($self->{PING}) {
    # try to ping the machine before update
    if (my $pid=fork) {
      waitpid($pid,0);
      my $returncode=($? >> 8);
      if ($returncode != 0) {
        # host is unreachable if fping doesn't return 0
        $self->{DISPLAY}->set_state($host,'unreachable');
        return;
      }
    } else {
      die "cannot fork: $!" unless defined $pid;
      #don't clutter the ouput
      open STDIN,'/dev/null'; open STDERR,'>/dev/null'; open STDOUT,'>/dev/null';
      exec '/usr/bin/fping','-q',$host;
    }
  }
  
  if (my $pid=fork) {
    $self->{HOSTPID}->{$host} = $pid;
  } else {
    die "cannot fork: $!" unless defined $pid;
    open STDIN,'/dev/null'; open STDERR,'>/dev/null';
    open STDOUT,">".$self->{LOGDIR}."/$host";
    exec $command,$host;
  } 
}

# extract state from a complete logfile
sub check_logfile {
  my ($self,$host) = (shift,shift);
  my $logfile=$self->{LOGDIR} . "/$host";
  open LOGFILE,$logfile;
  my $state=(exists $self->{HOSTPID}->{$host} ? 'started' : 'empty');
  while (<LOGFILE>) {
    if (/Fully Automatic Installation/) {
      $state=(exists $self->{HOSTPID}->{$host} ? 'running' : 'unfinished');
    }
    if (/An error occured/) {
      $state='error';
      last;
    }
    if (/Sav\S+ log files/) {
      $state='success';
    }
  }
  close LOGFILE;
  return $state;
}

sub init_hostlist {
  my $self=shift;
  my $randomize_order=shift;
  my @hostlist;

  # set state to waiting for all 
  map { $self->{DISPLAY}->set_state($_,'waiting') } @_;
  if ($randomize_order) {
    my %weight;
    map { $weight{$_}=rand; } @_;
    @{$self->{TO_DO}}=sort { $weight{$a} <=> $weight{$b} } @_;
  } else {
    @{$self->{TO_DO}}=@_;
  }
}

sub run {
  my $self=shift;
  my $running=0;
  foreach my $name (keys %{$self->{HOSTPID}}) {
    if ( waitpid($self->{HOSTPID}->{$name},WNOHANG)==0 ) {
      $running++;
    } else {
      delete $self->{HOSTPID}->{$name};
    } 
    $self->{DISPLAY}->set_state($name,$self->check_logfile($name));
  }
  
  # fork new processes if there are less running than possible
  while ($running<$self->{MAX_SIMULTANOUS}) {
    last unless my $host=shift @{$self->{TO_DO}};
    $self->start_one($host);
    $running++;
  }
  return $running;
}

sub max_simultanous {
  my $self = shift;
  return $self->{MAX_SIMULTANOUS} unless $self->{MAX_SIMULTANOUS}=shift;
}

package FAI::Updater::Display;
use strict;
# constructor
sub new {
  my $class = shift;
  my $self = {};
  bless($self,$class);
  $self->_init;
  return($self);
}

sub _init {
  my $self=shift;
  $self->{STATUS}={};
  $self->{ENABLED}=0;
}

sub enable {
  my $self=shift;
  $self->{ENABLED}=1;
}

sub disable {
  my $self=shift;
  $self->{ENABLED}=0;
}

sub set_state {
  my ($self,$key,$val) = (shift,shift,shift);
  $self->{STATUS}->{$key}=$val;
}

1; # so the require or use succeeds
