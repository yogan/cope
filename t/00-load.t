#!perl -T
use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Cope' );
}

diag( "Testing App::Cope $Cope::VERSION, Perl $], $^X" );
