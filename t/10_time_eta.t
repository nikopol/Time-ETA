use strict;
use Test::More;
use Time::ETA;
use YAML::Syck;

$|=1;

my $t = Time::ETA->new;
ok( eval { $t->percent==0 && $t->{count}==100 }, "object created without arg got right default values" );

my $n = 10;
$t = Time::ETA->new(10);
ok( eval { $t->percent==0 && $t->{count}==10 }, "object created with scalar got right default values" );

#while( $n-- ) {
#	print $t->tick."\n";
#	sleep 1;
#}

done_testing;

