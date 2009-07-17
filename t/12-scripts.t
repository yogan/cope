#!/usr/bin/env perl
use Test::More;

my @files = <scripts/*>;
plan tests => scalar @files;

for my $file (@files) {
  my $output = `perl -c $file 2>&1`;
  if ($output =~ /syntax OK/) {
    pass $file;
  } else {
    fail $file;
    print STDERR $output;
  }
}

