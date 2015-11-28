package Amling::Git::GBD::Action::RangeSystem;

use strict;
use warnings;

use Amling::Git::GBD::Action::WithStatus;

use base ('Amling::Git::GBD::Action::WithStatus');

sub execute2
{
    my $self = shift;
    my $state = shift;
    my $result = shift;

    my $plus = $result->{'RANGE'}->{'PLUS'};
    my $minus = $result->{'RANGE'}->{'MINUS'};
    my @command = $self->command($plus, (map { "^$_" } @$minus));
    (system(@command) == 0) || die join(' ', @command) . " failed: $!";

    return $state;
}

1;
