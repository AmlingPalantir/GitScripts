package Amling::Git::GBD::Action::Visible::next;

use strict;
use warnings;

use Amling::Git::GBD::Action::NextSystem;

use base ('Amling::Git::GBD::Action::NextSystem');

sub command
{
    my $self = shift;

    return ('git', 'checkout', @_);
}

1;
