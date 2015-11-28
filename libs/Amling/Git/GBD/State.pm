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

1;
