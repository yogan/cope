#!/usr/bin/env perl
use strict;
use warnings;

use App::Cope qw[mark colourise];
use Test::More tests => 2;

my $one = colourise sub{ mark qr{\w+} => qw[red] }, 'bran flakes';
$one =~ s/\033/\\033/g;
is( $one, "\\033[31mbran\\033[0m flakes", "mark" );

my $two = colourise sub { mark qr{^\|_\s.+} => 'magenta' }, '|_ HTML Title: Document Moved';
$two =~ s/\033/\\033/g;
is( $two, "\\033[35m|_ HTML Title: Document Moved\\033[0m", "line" );
