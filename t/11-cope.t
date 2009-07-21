#!/usr/bin/env perl
use Test::More tests => 14;
use App::Cope qw[mark line colourise];

sub test($&$$) {
  my ( $description, $sub, $in, $expected ) = @_;
  my $got = colourise( $sub, $in );
  $got =~ s/\033/\\E/g;
  is( $got, $expected, $description );
}

# Mark tests.

test 'mark with simple regex' => sub {
  mark qr{\w+} => qw[red];
},
  'bran flakes',
  '\\E[31mbran\\E[0m flakes';

test 'mark with more complicated regex' => sub {
  mark qr{^\|_\s.+} => 'magenta';
},
  '|_ HTML Title: Document Moved',
  '\\E[35m|_ HTML Title: Document Moved\\E[0m';

# Line tests

test 'line with one group' => sub {
  line qr{(\w+)} => 'red';
},
  'bran flakes',
  '\\E[31mbran\\E[0m \\E[31mflakes\\E[0m';

test 'line with two groups' => sub {
  line qr{^(\|_)\s(.+)} => 'magenta bold', 'magenta';
},
  '|_ HTML Title: Document Moved',
  '\\E[35;1m|_\\E[0m \\E[35mHTML Title: Document Moved\\E[0m';

test '^ only applied once' => sub {
  line qr{^(.)} => 'red';
},
  'hello',
  '\E[31mh\E[0mello';

sub configure_process {
  line qr{^checking .+\.{3} (.+)} => sub {
    my $r = shift;

    # two most common cases
    return 'green bold' if $r =~ m{(?:\(cached\)\s)?yes|none (?:needed|required)|done|ok};
    return 'red bold' if $r =~ m{no};

    # check for a found program or flag
    if ($r =~ m{^(?:(?:/usr)?/bin/)?(\w+)} and m{$1.*\.{3}}) {
      return 'green bold';
    }

    return 'yellow bold';
  };
}

test 'subroutine 1' => \&configure_process,
  'checking for sys/stat.h... yes',
  'checking for sys/stat.h... \\E[32;1myes\\E[0m';

test 'subroutine 2' => \&configure_process,
  'checking how to run the C preprocessor... gcc -E',
  'checking how to run the C preprocessor... \\E[33;1mgcc -E\\E[0m';

test 'subroutine 3' => \&configure_process,
  'checking for a sed that does not truncate output... /bin/sed',
  'checking for a sed that does not truncate output... \\E[32;1m/bin/sed\\E[0m';

test 'two lines matching the same text 1' => sub {
  line qr{(\d+)} => 'yellow';
  line qr{\d+\s+(\S+)} => 'blue';
},
  'go go 1234 shake boom!',
  'go go \\E[33m1234\\E[0m \\E[34mshake\\E[0m boom!';

test 'two lines matching the same text 2' => sub {
  line qr{\d+\s+(\S+)} => 'blue';
  line qr{(\d+)} => 'yellow';
},
  'go go 1234 shake boom!',
  'go go \\E[33m1234\\E[0m \\E[34mshake\\E[0m boom!';

test 'consecutive groups 1' => sub {
  mark qr{A} => 'on_red';
  mark qr{B} => 'red';
},
  'ABC',
  '\\E[41mA\\E[0;31mB\\E[0mC';

test 'consecutive groups 2' => sub {
  line qr{^(?:In file included from )?([^:]+:)([^:]+:)} => 'green bold', 'green';
},
  'fileschanged.c:95: error: too many arguments to function ‘perror’',
  '\\E[32;1mfileschanged.c:\\E[0;32m95:\\E[0m error: too many arguments to function ‘perror’';

test 'consecutive groups 3' => sub {
  mark qr{This is bold, } => 'green bold';
  mark qr{and this is, too!} => 'blue bold';
},
  'This is bold, and this is, too!',
  '\\E[32;1mThis is bold, \\E[34;1mand this is, too!\\E[0m';

test 'consecutive groups 4' => sub {
  mark qr{This is bold } => 'green bold';
  mark qr{but this should not be} => 'on_red';
},
  'This is bold but this should not be',
  '\\E[32;1mThis is bold \\E[0;41mbut this should not be\\E[0m';
