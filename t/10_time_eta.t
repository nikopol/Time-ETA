use strict;
use Test::More;
use Time::ETA;
use YAML::Syck;

$|=1;

my $t = Time::ETA->new;
ok( eval { $t->percent==0 && $t->{count}==100 }, "object created without arg got right default values" );

my $n = 20;
$t = Time::ETA->new($n)->fmt("{P}% ETA{I}{H}h{M}m{S}s {B}\n");
ok( eval { $t->percent==0 && $t->{count}==$n }, "object created with scalar got right default values" );

print $t->tick while $n--;

done_testing;

