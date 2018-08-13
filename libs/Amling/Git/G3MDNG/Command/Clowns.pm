package Amling::Git::G3MDNG::Command::Clowns;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseReplace;

use base ('Amling::Git::G3MDNG::Command::BaseReplace');

sub new
{
    my $class = shift;
    my $aliases = shift;
    my $idx = shift;

    my $this = $class->SUPER::new($aliases);

    $this->{'IDX'} = $idx;

    return $this;
}

sub handle3
{
    my $this = shift;
    my $rest = shift;

    return [map { ['RESOLVED', $_] } @{$rest->[$this->{'IDX'}]}];
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['<', 'ours'], 1));
Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['>', 'theirs'], 5));

1;
