package Amling::Git::GBD::Action::Visible::load;

use strict;
use warnings;

use Amling::Git::GBD::Action::LoadSave;
use Amling::Git::GBD::Utils;

use base ('Amling::Git::GBD::Action::LoadSave');

sub execute2
{
    my $self = shift;
    my $state = shift;
    my $file = shift;

    $state = Amling::Git::GBD::Utils::load_object($file);
    if(!$state->isa('Amling::Git::GBD::State'))
    {
        die "State is not a Amling::Git::GBD::State?";
    }

    return $state;
}

1;
