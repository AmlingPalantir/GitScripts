package Amling::Git::GBD::Action::Visible::log;

use strict;
use warnings;

use Amling::Git::GBD::Action::RangeSystem;

use base ('Amling::Git::GBD::Action::RangeSystem');

sub command
{
    my $self = shift;

    return ('git', 'log', @_);
}

1;
