package Amling::Git::GBD::Action::Visible::range;

use strict;
use warnings;

use Amling::Git::GBD::Action::RangeSystem;

use base ('Amling::Git::GBD::Action::RangeSystem');

sub defaults
{
    my $clazz = shift;
    return
    (
        $clazz->SUPER::defaults(),
        'COMMAND' => 'echo',
    );
}

sub options
{
    my $self = shift;
    return
    (
        $self->SUPER::options(),
        'command=s' => 'COMMAND',
    );
}

sub command
{
    my $self = shift;

    return $self->{'COMMAND'} . join('', map { " $_"} @_);
}

1;
