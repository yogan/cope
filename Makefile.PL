use inc::Module::Install;

# metadata
name 'Cope';
all_from 'lib/App/Cope.pm';

# use 5.10 for given/when construct
perl_version '5.010';

# requirements
requires 'List::MoreUtils';
requires 'IO::Handle';
requires 'IO::Pty';
requires 'IO::Stty';
requires 'Term::ANSIColor';
requires 'File::ShareDir';
requires 'Env::Path';

# testing
test_requires 'Test::More';

# install the scripts
install_share 'scripts';

# go go go!
auto_install;
WriteAll;
