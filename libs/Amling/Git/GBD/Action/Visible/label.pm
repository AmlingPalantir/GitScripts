package Amling::Git::GBD::Action::Visible::label;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;
use Amling::Git::Utils;

use base ('Amling::Git::GBD::Action::Simple');

sub defaults
{
    my $class = shift;

    return
    (
        'COMMIT' => 'HEAD',
        'LABEL' => $class->label(),
    );
}

sub options
{
    my $self = shift;
    return
    (
        'commit=s' => 'COMMIT',
        ($self->label() ? () : ('label=s' => 'LABEL')),
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
    my $label = $self->{'LABEL'};
    my $old_label = $state->set_label($commit, $label);

    if(defined($old_label))
    {
        print "Relabelled $commit: $old_label -> $label\n";
    }
    else
    {
        print "Labelled $commit: $label\n";
    }

    return $state;
}

sub label
{
    return undef;
}

1;
