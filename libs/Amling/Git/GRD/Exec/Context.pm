package Amling::Git::GRD::Exec::Context;

use strict;
use warnings;

use Amling::Git::Utils;

sub new
{
    my $class = shift;

    my $self =
    {
        'HEAD' => undef,
    };

    bless $self, $class;

    return $self;
}

sub get
{
    my $self = shift;
    my $item = shift;
    my $def = shift;

    if(defined($def) && !defined($self->{$item}))
    {
        $self->{$item} = $def;
    }

    return $self->{$item};
}

sub set
{
    my $self = shift;
    my $item = shift;
    my $def = shift;

    $self->{$item} = $def;
}

sub get_head
{
    my $self = shift;

    my $commit = $self->{'HEAD'};

    if(!defined($commit))
    {
        die "get_head() called with HEAD unset";
    }

    return $commit;
}

sub materialize_head
{
    my $self = shift;
    my $commit = shift;

    if(defined($commit))
    {
        $self->{'HEAD'} = $commit;
    }
    else
    {
        $commit = $self->{'HEAD'};

        if(!defined($commit))
        {
            die "materialize_head() called with HEAD unset";
        }
    }

    Amling::Git::Utils::run_system("git", "checkout", $commit) || die "Cannot checkout $commit";
}

sub set_head
{
    my $self = shift;
    my $commit = shift;

    $self->{'HEAD'} = $commit;
}

sub uptake_head
{
    my $self = shift;

    $self->{'HEAD'} = Amling::Git::Utils::convert_commitlike('HEAD');
}

sub get_hooks_stack
{
    my $self = shift;
    return $self->get('hooks-stack', [{}]);
}

sub get_hooks
{
    my $self = shift;
    my $event = shift;

    my @ret;
    for my $frame (@{$self->get_hooks_stack()})
    {
        push @ret, @{$frame->{$event} || []};
    }

    return \@ret;
}

sub run_hooks
{
    my $self = shift;
    my $event = shift;
    my @env = @_;

    if(@env)
    {
        my $k = shift @env;
        my $v = shift @env;
        local $ENV{"GRD_HOOK_$k"} = $v;
        return $self->run_hooks($event, @env);
    }

    for my $cmd (@{$self->get_hooks($event)})
    {
        print "Interpretting hook for $event: " . $cmd->str() . "\n";
        $cmd->execute($self);
    }
}

1;
