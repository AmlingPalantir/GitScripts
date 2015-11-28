package Amling::Git::GBD::Action::Visible::before;

use strict;
use warnings;

use Amling::Git::GBD::Action::Visible::label;

use base ('Amling::Git::GBD::Action::Visible::label');

sub label
{
    return 'before';
}

1;
