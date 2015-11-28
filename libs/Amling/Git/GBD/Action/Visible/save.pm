package Amling::Git::GBD::Action::Visible::save;

use strict;
use warnings;

use Amling::Git::GBD::Action::LoadSave;
use Amling::Git::GBD::Utils;
use File::Basename;

use base ('Amling::Git::GBD::Action::LoadSave');

sub execute2
{
    my $self = shift;
    my $state = shift;
    my $file = shift;

    my $dir = dirname($file);
    (system('mkdir', '-p', '--', $dir) == 0) || die "Could not mkdirs to $dir: $!";
    Amling::Git::GBD::Utils::save_object($file, $state);

    return $state;
}

1;
