package Amling::Git::GBD::Action::Visible::next;

use strict;
use warnings;

use Amling::Git::GBD::Action::NextSystem;

use base ('Amling::Git::GBD::Action::NextSystem');

sub command
{
    my $self = shift;

    return ('echo', @_);
}

1;
