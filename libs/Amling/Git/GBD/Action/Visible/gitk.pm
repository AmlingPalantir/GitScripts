package Amling::Git::GBD::Action::Visible::gitk;

use strict;
use warnings;

use Amling::Git::GBD::Action::RangeSystem;

use base ('Amling::Git::GBD::Action::RangeSystem');

sub command
{
    my $self = shift;

    return ('gitk', @_);
}

1;
