#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use App::Cope q[get];

is( get( 'red', 'foo' ), 'red', "Scalar" );

my %stuff = ( 'PASS' => 'green', 'FAIL' => 'red' );
is( 'green', get( \%stuff, 'PASS' ), "Hash" );
is( '',   get( \%stuff, 'bar' ),  "Hash fallback" );

my @things = ( 'blue bold', 'magenta' );
is( 'blue bold', get( \@things, 'gunther' ), "Array" );
is( 'magenta',   get( \@things, 'gunther' ), "Array shift" );

sub num {
  return 'green bold' if shift > 0;
  return 'green';
}

is( 'green bold', get( \&num, 11 ), "Sub" );
is( 'green',      get( \&num, 0 ),  "Sub fallback" );
