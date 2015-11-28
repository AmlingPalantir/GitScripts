package Amling::Git::GBD::Action::Visible::bad;

use strict;
use warnings;

use Amling::Git::GBD::Action::Visible::label;

use base ('Amling::Git::GBD::Action::Visible::label');

sub label
{
    return 'after';
}

1;
