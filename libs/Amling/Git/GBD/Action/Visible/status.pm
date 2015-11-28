package Amling::Git::GBD::Action::Visible::status;

use strict;
use warnings;

use Amling::Git::GBD::Action::WithStatus;

use base ('Amling::Git::GBD::Action::WithStatus');

sub execute2
{
    my $self = shift;
    my $state = shift;
    my $result = shift;

    my $range = $result->{'RANGE'};
    my $plus = $range->{'PLUS'};
    my @minus = @{$range->{'MINUS'}};
    my $delta_weight = $range->{'WEIGHT'};
    my $delta_count = $range->{'COUNT'};

    print "Range: " . join('', map { "^$_ " } @minus) . "$plus\n";
    print "Range weight: $delta_weight\n";
    print "Range commit count: $delta_count\n";

    for my $line (@{$result->{'STATUS'}})
    {
        print "$line\n";
    }

    print "Next: " . $result->{'NEXT'} . "\n";

    return $state;
}

1;
