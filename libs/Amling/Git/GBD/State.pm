package Amling::Git::GBD::State;

use strict;
use warnings;

use Amling::Git::Utils;

sub new
{
    my $class = shift;

    my $commits = {};

    my $self =
    {
        'TIPS' => {},
        'COMMITS' => {},
        'LABELS' => {},
    };

    bless $self, $class;

    return $self;
}

sub set_label
{
    my $self = shift;
    my $commit = shift;
    my $label = shift;

    $self->load($commit);

    my $old_label = $self->{'COMMITS'}->{$commit}->{'LABEL'};
    if(defined($old_label))
    {
        delete(($self->{'LABELS'}->{$old_label} ||= {})->{$commit});
    }

    $self->{'COMMITS'}->{$commit}->{'LABEL'} = $label;
    if(defined($label))
    {
        ($self->{'LABELS'}->{$label} ||= {})->{$commit} = 1;
    }

    return $old_label;
}

sub get_label
{
    my $self = shift;
    my $commit = shift;

    $self->load($commit);

    return $self->{'COMMITS'}->{$commit}->{'LABEL'};
}

sub commits_for_label
{
    my $self = shift;
    my $label = shift;

    return sort(keys(%{$self->{'LABELS'}->{$label} || {}}));
}

sub get_commit
{
    my $self = shift;
    my $commit = shift;

    $self->load($commit);

    return $self->{'COMMITS'}->{$commit}->{'OBJECT'};
}

sub load
{
    my $self = shift;
    my @commits = @_;

    @commits = grep { !$self->{'COMMITS'}->{$_} } @commits;
    return unless(@commits);

    my @args = (@commits, (map { "^$_" } keys(%{$self->{'TIPS'}})));
    $self->{'TIPS'}->{$_} = 1 for(@commits);
    my $cb = sub
    {
        my $object = shift;
        my $commit = $object->{'hash'};
        delete $self->{'TIPS'}->{$_} for(@{$object->{'parents'}});
        die if($self->{'COMMITS'}->{$commit});
        $self->{'COMMITS'}->{$commit} =
        {
            'OBJECT' => $object,
            'LABEL' => undef,
            'WEIGHTS' => {},
        };
    };
    Amling::Git::Utils::log_commits([@args], $cb);
}

sub combined_weight
{
    my $self = shift;
    my $weight_code = shift;
    my @commits = @_;

    ...
}

1;
