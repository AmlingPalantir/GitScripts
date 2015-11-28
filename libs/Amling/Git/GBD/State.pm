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

sub delta_weight
{
    my $self = shift;
    my $weight_code = shift;
    my $plus = shift;
    my $minus = shift;

    $self->load(@$plus);

    my $weight_sub = $self->_weight_sub($weight_code);

    my $weight = 0;
    $self->dfs($plus, $minus, sub
    {
        my $commit = shift;
        $weight += $weight_sub->($commit);
        return 1;
    });

    return $weight;
}

sub _weight_sub
{
    my $self = shift;
    my $weight_code = shift;

    my $uncached_sub = eval "sub { my \$c = shift; $weight_code }";
    die "Compilation of $weight_code failed: $@" if($@);

    return sub
    {
        my $commit = shift;
        my $commit_data = $self->{'COMMITS'}->{$commit};

        my $ret = $commit_data->{'WEIGHTS'}->{$weight_code};
        if(!defined($ret))
        {
            $ret = $commit_data->{'WEIGHTS'}->{$weight_code} = $uncached_sub->($commit_data->{'OBJECT'});
        }

        return $ret;
    };
}

sub dfs
{
    my $self = shift;
    my $plus = shift;
    my $minus = shift;
    my $cb = shift;

    my @q = @$plus;
    my %already = (map { $_ => 1 } @$minus);
    while(@q)
    {
        my $commit = shift @q;
        next if($already{$commit});
        $already{$commit} = 1;

        my $r = $cb->($commit);
        if($r < 0)
        {
            return;
        }
        if($r > 0)
        {
            push @q, @{$self->get_commit($commit)->{'parents'}};
        }
    }
}

1;
