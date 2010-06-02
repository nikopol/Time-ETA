use inc::Module::Install;
name 'Time-ETA';
all_from 'lib/Time/ETA.pm';

requires 'Time::HiRes';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
