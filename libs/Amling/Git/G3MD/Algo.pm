package Amling::Git::G3MD::Algo;

use strict;
use warnings;

sub dfs
{
    my $cb = shift;

    my $first = $cb->{'first'};
    my $last = $cb->{'last'};

    my %already = ($first => undef);
    my %q = (0 => [$first]);
    SRCH:
    for(my $d = 0; 1; ++$d)
    {
        # have to leave in %q since zero length steps are a thing
        my $sqr = $q{$d};

        next unless(defined($sqr));
        next unless(@$sqr);

        while(@$sqr)
        {
            my $e = shift @$sqr;

            for my $ne_pair (@{$cb->{'step'}->($e)})
            {
                my ($ne, $step) = @$ne_pair;

                next if($already{$ne});
                $already{$ne} = $e;

                last SRCH if($ne eq $last);

                my $d2 = $d + $step;
                push @{$q{$d2} ||= []}, $ne;
            }
        }

        delete($q{$d});
    }

    my $pos = $last;
    my @ret;
    while(1)
    {
        my $prev = $already{$pos};
        last unless(defined($prev));

        unshift @ret, $cb->{'result'}->($prev, $pos);

        $pos = $prev;
    }

    return \@ret;
}

1;
