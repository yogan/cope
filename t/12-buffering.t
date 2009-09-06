#!/usr/bin/env perl
use Test::More;
use App::Cope qw[run_with line];
use Term::ANSIColor qw[colored];

# This test, for various reasons, is a program that runs a program
# that runs a program that pretends to be an actual program. So pay
# attention!

# It uses `run_with' instead of `run' to bypass the output-to-tty
# checking.

sub process {
  line qr{(--)} => 'green';
}

my %results = (

  # With line buffering off, each hyphen will be processed on a
  # separate call to process, so they won't be highlighted.
  0 => "Opening--Closing\n",

  # With it on, the first hyphen will be buffered, so they will be
  # highlighted.
  1 => "Opening" . colored( '--' => 'green' ) . "Closing\n",

);

my $arg = shift @ARGV;
if ( defined $arg ) {
  if ( $arg eq 'output' ) {
    # Pretend to be a program that outputs some stuff.
    print "Opening-";
    sleep 1;
    print "-Closing\n";
  }
  else {
    # Run that program, and scan its (possibly-buffered) output.
    $App::Cope::line_buffered = $arg;
    run_with( \&process, 'perl', $0, 'output' );
  }
}
else {
  plan tests => 2;
  # Run the programs, and ok the tests.
  for ( 0 .. 1 ) {
    my $out = `perl $0 $_`;
    is $out, $results{$_};
  }
}

