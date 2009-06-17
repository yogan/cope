#!/usr/bin/env perl
use strict;
use warnings;

use App::Cope qw[line colourise];
use Test::More tests => 4;

my $one = colourise { line qr{(\w+)} => qw[red]; } 'bran flakes';
$one =~ s/\033/\\033/g;
is( $one, "\\033[31mbran\\033[0m \\033[31mflakes\\033[0m", "line" );

my $two = colourise { line qr{^(\|_)\s(.+)} => 'magenta bold', 'magenta' } '|_ HTML Title: Document Moved';
$two =~ s/\033/\\033/g;
is( $two, "\\033[35;1m|_\\033[0m \\033[35mHTML Title: Document Moved\\033[0m", "line" );

my $three = colourise {
  line qr{(\d+)} => 'yellow';
  line qr{\d+\s+(\S+)} => 'blue';
} 'go go 1234 shake boom!';

$three =~ s/\033/\\033/g;
is(
   $three,
   "go go \\033[33m1234\\033[0m \\033[34mshake\\033[0m boom!",
   "transposed lines 1"
  );

my $four = colourise {
  line qr{\d+\s+(\S+)} => 'blue';
  line qr{(\d+)} => 'yellow';
} 'go go 1234 shake boom!';
$four =~ s/\033/\\033/g;

is(
   $four,
   "go go \\033[33m1234\\033[0m \\033[34mshake\\033[0m boom!",
   "transposed lines 2"
  );
