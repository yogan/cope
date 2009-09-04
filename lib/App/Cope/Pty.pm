package App::Cope::Pty;
use strict;
use warnings;

=head1 NAME

App::Cope::Pty - Pseudo-tty functions for B<cope>.

=head1 DESCRIPTION

B<Note:> This is part of L<cope>, and doesn't make much of an effort
to fit in anywhere else. If you want a nice pty library, use
L<IO::Pty> or L<IO::Pty::Easy>.

cope uses a pseudo-tty for reading in from a process. This is favoured
above pipes, because ptys allow for non-buffered input, instead of
waiting for the program to complete before getting any output from it.

=cut

use Carp;
use IO::Pty;

=head1 METHODS

=head2 new()

The constructor initialises and returns the pty, and croaks if it
fails.

C<spawn> should be called sometime after this, to run a program.

=cut

sub new {
  my $class = shift;
  my $self;
  $self->{pty} = new IO::Pty or croak "Failed pty: $!";
  bless $self, $class;
  return $self;
}

=head2 spawn( @args )

Forks a new process with C<exec>, with C<stdin>, C<stderr> and
C<stdout> reopened to the pty. Croaks or carps if anything goes wrong
(Failed piping or reopening).

Leaves the child in the C<exec> call and returns nothing important.

=cut

sub spawn {
  my ( $self, @args ) = @_;

  # set up the pipe from which to read
  pipe( my $readp, my $writep ) or croak "Failed pipe: $!";
  $writep->autoflush;

  # the program runs independently in a child process so we can get
  # its output without interfering with it
  $self->{pid} = fork;
  croak "Fork failed: $!" unless defined $self->{pid};

  if ( $self->{pid} == 0 ) {    # we are the child
    close $readp or carp "Failed close: $!";
    $self->{pty}->make_slave_controlling_terminal;
    close $self->{pty};

    # disassociate from the terminal
    POSIX::setsid or carp "Failed setsid: $!";
    my $tty = $self->{pty}->slave;
    $tty->clone_winsize_from( \*STDIN );

    # set stdin to raw, so keypresses get passed straight through
    IO::Stty::stty( $tty, 'raw', '-echo' );

    # associate with a new terminal
    my $fileno = $tty->fileno;
    my $name   = $tty->ttyname;
    croak "Failed ttyname: $!" unless defined $name;

    # make the standard file descriptors point to our pty rather than the
    # terminal we're printing to

    close STDIN;
    open STDIN, '<&', $fileno
      or croak "Couldn't reopen stdin for reading to $name: $!";

    close STDOUT;
    open STDOUT, '>&', $fileno
      or croak "Couldn't reopen stdout for reading to $name: $!";

    close STDERR;
    open STDERR, '>&', $fileno
      or croak "Couldn't reopen stderr for reading to $name: $!";

    close $tty;

    # run the process (exec should never return)
    { exec(@args); };
    print { $writep } $! + 0 or carp "Failed print: $!";
    croak "Cannot exec: $!";
  }

  else {    # we are the parent
    #close STDIN;
    close $writep or carp "Failed close: $!";
    $self->{pty}->close_slave;
    $self->{pty}->set_raw;

    # and don't do anything else!
  }
}

=head2 read()

Reads data from the process that's running on the pty.

C<read> assumes that both the pty and its process have been set up
correctly, and does no checking. Then it does a blocking read, so
there'd better be something to read on the other end.

Returns up to 4096 bytes' worth of read data. If there's any data left
over, it will be read during the next cycle.

=cut

sub read {
  my $self = shift;
  my $nchars = sysread( $self->{pty}, my $buf, 4096 );
  $buf = '' if defined $nchars && $nchars == 0;
  return $buf;
}

=head2 close()

Kills the process running and closes the pty.

=cut

sub close {
  shift->{pty}->close;
}

1;

__END__
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 2
#   fill-column: 70;
#   indent-tabs-mode: nil
# End:
# vi: set ts=2 sts=2 sw=2 tw=70 et
