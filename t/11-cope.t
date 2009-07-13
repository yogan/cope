#!/usr/bin/env perl
use Test::More tests => 10;
use App::Cope qw[mark line colourise];

sub test($&$$) {
  my ( $description, $sub, $in, $expected ) = @_;
  my $got = colourise( $sub, $in );
  $got =~ s/\033/\\E/g;
  is( $got, $expected, $description );
}

# Mark tests.

test 'mark' => sub {
  mark qr{\w+} => qw[red];
},
  'bran flakes',
  '\\E[31mbran\\E[0m flakes';

test 'mark 2' => sub {
  mark qr{^\|_\s.+} => 'magenta';
},
  '|_ HTML Title: Document Moved',
  '\\E[35m|_ HTML Title: Document Moved\\E[0m';

test 'simple' => sub {
  line qr{(\w+)} => 'red';
},
  'bran flakes',
  '\\E[31mbran\\E[0m \\E[31mflakes\\E[0m';

test 'line' => sub {
  line qr{^(\|_)\s(.+)} => 'magenta bold', 'magenta';
},
  '|_ HTML Title: Document Moved',
  '\\E[35;1m|_\\E[0m \\E[35mHTML Title: Document Moved\\E[0m';

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

test 'transposition 1' => sub {
  line qr{(\d+)} => 'yellow';
  line qr{\d+\s+(\S+)} => 'blue';
},
  'go go 1234 shake boom!',
  'go go \\E[33m1234\\E[0m \\E[34mshake\\E[0m boom!';

test 'transposition 2' => sub {
  line qr{\d+\s+(\S+)} => 'blue';
  line qr{(\d+)} => 'yellow';
},
  'go go 1234 shake boom!',
  'go go \\E[33m1234\\E[0m \\E[34mshake\\E[0m boom!';

test 'no colour leaking' => sub {
  mark qr{A} => 'on_red';
  mark qr{B} => 'red';
},
  'ABC',
  '\\E[41mA\\E[31mB\\E[0mC';
