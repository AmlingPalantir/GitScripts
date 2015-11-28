package Amling::Git::GBD::Action::Visible::label;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;
use Amling::Git::Utils;

use base ('Amling::Git::GBD::Action::Simple');

sub defaults
{
    return
    (
        'COMMIT' => 'HEAD',
        'LABEL' => undef,
    );
}

sub options
{
    return
    (
        'commit=s' => 'COMMIT',
        'label=s' => 'LABEL',
    );
}

sub validate
{
    my $self = shift;
    $self->{'LABEL'} || die "Required: --label";
}

sub execute
{
    my $self = shift;
    my $state = shift;

    my $commit = Amling::Git::Utils::convert_commitlike($self->{'COMMIT'});
    $state->set_label($commit, $self->{'LABEL'});

    return $state;
}

1;
