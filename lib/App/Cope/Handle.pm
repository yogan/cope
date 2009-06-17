package App::Cope::Handle;
use strict;
use warnings;

=head1 NAME

Cope::Handle - Input handle functions for F<cope>.

=head1 SYNOPSIS

  # See F<cop.pm> for Cope::Handle in action

  my $fh = new Cope::Handle;

  select( my $rout = $fh->bits, (undef) x 3 );

  my @input = $fh->read;


=head1 DESCRIPTION

B<Note:> This is part of F<cope>, and doesn't make much of an effort
to fit in anywhere else. Try using F<IO::Handle> instead.

F<cope> uses an C<IO::Handle> to C<stdin> to read user input and pass
it along to the program (whether or not the program likes it).

This module is simple enough, but it mirrors F<Cope::Pty> in
implementation details.

=cut

use Carp;
use IO::Handle;

=head1 METHODS

=head2 new()

The constructor initialises and returns the handle, and croaks if it
fails. It also associates opens the handle to C<stdin>, and sets the
bits for C<select>.

=cut

sub new {
  my $class = shift;
  my $self;
  $self->{fh} = new IO::Handle or croak "Failed handle: $!";
  $self->{fh}->fdopen( fileno STDIN, 'r' );
  $self->{fh}->autoflush;
  vec( $self->{bits} = '', $self->{fh}->fileno, 1 ) = 1;
  bless $self, $class;
}

=head2 read()

Reads data from the filehandle (standard input).

C<read> assumes that the handle has been set up correctly, and does no
checking. B<Most importantly>, it assumes that there's something to
read; if there isn't, it just waits until there is something. F<cope>
checks that there's something to read with C<select> on the filehandle
before calling this.

Returns up to 16 bytes' worth of read data, and the number of bytes
read. Usually, input is small enough for this to not be broken; if it
is, the remaining input will be read during the next cycle.

The return array is intended to be passed into C<syswrite> - the order
of the arguments is intentionally identical.

=cut

sub read {
  my $self = shift;
  my $nchars = $self->{fh}->sysread( my $buf, 16 );
  $buf = '' if defined $nchars && $nchars == 0;
  return ( $buf, $nchars );
}

=head2 close()

Closes the filehandle.

=cut

sub close {
  shift->{fh}->close or carp "Failed close: $!";
}

1;
