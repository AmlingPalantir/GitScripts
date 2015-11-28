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

    for my $line (@{$result->{'STATUS'}})
    {
        print "$line\n";
    }

    return $state;
}

1;
