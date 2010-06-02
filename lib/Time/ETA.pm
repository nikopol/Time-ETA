package Time::ETA;

use strict;
use warnings;

use Time::HiRes qw(gettimeofday tv_interval);

our $VERSION = '0.0.01';

sub new {
	my($class,$o) = @_;
	$o = { max => defined $o ? 0+$o : 100 } unless ref($o) eq 'HASH';
	my $self = {
		max   => 100,
		min   => 0,
		indic => ' ',
		bar   => 0,
		%$o,
		time  => [gettimeofday],
		eta   => 0,
	};
	bless $self, $class;
	$self->{count} = $self->{max} - $self->{min};
	$self->{done} = ($o->{set}||0) - $self->{min};
	$self->fmt( $o->{fmt} );
	$self;
}

sub fmt {
	my( $self, $fmt ) = @_;
	$fmt ||= '{P}% ETA{I}{H}h{M}m{S}s';
	$self->{bar} = 20 if $fmt =~ /{B}/ && !$self->{bar};
	$fmt =~ s/%/%%/g;
	$fmt =~ s/{P}/%1\$d/g;
	$fmt =~ s/{I}/%2\$s/g;
	$fmt =~ s/{H}/%3\$d/g;
	$fmt =~ s/{M}/%4\$02d/g;
	$fmt =~ s/{S}/%5\$02d/g;
	$fmt =~ s/{B}/%6\$s/g;
	$self->{fmt} = $fmt;
	$self;
}

sub tick {
	shift->inc(shift)->get;
}

sub set {
	my($self,$set) = @_;
	$self->inc( ($set - $self->{min}) - $self->{done} );
}

sub inc {
	my($self,$delta) = @_;
	$self->{done} += defined $delta ? 0+$delta : 1;
	my $eta = (tv_interval($self->{time}) / $self->{done}) * ($self->{count} - $self->{done});
	$self->{indic} = ($eta>$self->{eta}) ? '+' : '-';
	$self->{eta} = ${eta};
	$self;
}

sub percent {
	my $self = shift;
	$self->{count} ? int(100.0 * $self->{done} / $self->{count}) : 0;
}

sub bar {
	my $self = shift;
	return '' unless $self->{bar};
	return ' ' x $self->{bar} unless $self->{bar}>2;
	my $w = $self->{bar} - 2;
	my $x = $self->{count} ? int(0.5 + ($w * $self->{done} / $self->{count})) : 0;
	my $b = $x ? '=' x ($x-1) . '>' : '';
	my $r = ' ' x ($w-$x);
	"[$b$r]";
}

sub get {
	my $self = shift;
    my $eta = int($self->{eta});
	my $m = int($eta/60);
	sprintf $self->{fmt}, $self->percent, $self->{indic}, int($m/60), $m%60, $eta%60, $self->bar;
}

1;
__END__

=head1 NAME

Time::ETA

=head1 SYNOPSIS

the following code display a string like "100% ETA-2h34m56s"

 use Time::ETA;
 $eta = Time::ETA->new;
 print $eta->tick."\n" for($i=0;$i<100;$i++);

one more way to do it
 
 use Time::ETA;
 $eta = Time::ETA->new($max=100);
 print $eta->inc->get."\n" while $max--;

and again

 use Time::ETA;
 $max = 100;
 $eta = Time::ETA->new({ min=>0, max=>$max, set=>0, fmt=>"%P% ETA%I%Hh%Mm%Ss\n" });
 print $eta->set($i)->format for( $i=0; $i<$max; ++$i );

=head1 DESCRIPTION

Time::ETA is another Estimated Time of Arrival

=head2 METHODS
 
=over 4

=item B<new>

=item B<new>(count)

=item B<new>({min=>int,max=>int,set=>int,fmt=>str,bar=>int})


I<parameters>

 count: how many iteration you will have (default=100).
 min  : you start a this iteration (default=0).
 max  : you end a this iteration (default=100).
 set  : you are actually (default=0).
 bar  : progress bar with in character (default=20)
 fmt  : the format you want (default={P} ETA{I}{H}h{M}m{S}s eg: 33% ETA-5h12m55s).
        {P} = percent
        {I} = relative indicator for one iteration's average time (+ or -)
        {H} = hours
        {M} = minutes
        {S} = seconds
        {B} = progress bar
 
I<return> a blessed object

=item B<fmt>(format)

 set format (see new for details)
 eg:

   my $eta = Time::ETA->new(10)->fmt("{B}\n");

=item B<tick>

=item B<tick>(delta)

increment your iteration's count.

I<parameter>

 delta : how many iteration have you done (default=1).

I<return> string with your ETA formatted


=item B<inc>

=item B<inc>(delta)

add a delta to your iteration's count.

I<parameter>

 delta: how many iteration you have done (default=1).

I<return> self


=item B<set>(current)

set your iteration to a non-relative value.

I<parameter>

 current : at what iteration you are.

I<return> self


=item B<percent>

I<return> the achievment percent

=item B<bar>

I<return> the current progress bar

=item B<eta>

I<return> the estimated time of arrival in seconds


=item B<get>

I<return> the estimated time of arrival formated (see B<new> method).

=back

=head1 AUTHOR

niko E<lt>nikomomo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
