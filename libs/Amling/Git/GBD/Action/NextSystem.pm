package Amling::Git::GBD::Action::NextSystem;

use strict;
use warnings;

use Amling::Git::GBD::Action::WithStatus;

use base ('Amling::Git::GBD::Action::WithStatus');

sub execute2
{
    my $self = shift;
    my $state = shift;
    my $result = shift;

    my $next = $result->{'NEXT'};
    my @command = $self->command($next);
    (system(@command) == 0) || die join(' ', @command) . " failed: $!";

    return $state;
}

1;
