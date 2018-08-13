package Amling::Git::G3MDNG::Command::Merge;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::Base;

use base ('Amling::Git::G3MDNG::Command::Base');

sub new
{
    my $class = shift;
    my $aliases = shift;
    my $dir = shift;

    my $this = $class->SUPER::new($aliases);

    $this->{'DIR'} = $dir;

    bless $this, $class;

    return $this;
}

sub args_regex
{
    return qr/(?:\s(\d+))?/;
}

sub handle2
{
    my $this = shift;
    my $state = shift;
    my $ct = shift || 1;

    my $s1 = $state->current_pos();
    my $s2 = $state->current_pos() + $ct * $this->{'DIR'};

    if($s2 < $s1)
    {
        ($s1, $s2) = ($s2, $s1);
    }

    $state->merge($s1, $s2 + 1);
    $state->mark_dirty();

    return 1;
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['mn', 'mnext'], 1));
Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['mp', 'mprev', 'mprevious'], -1));

1;
