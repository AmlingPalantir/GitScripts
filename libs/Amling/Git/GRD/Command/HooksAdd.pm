package Amling::Git::GRD::Command::HooksAdd;

use strict;
use warnings;

use Amling::Git::GRD::Command;
use Amling::Git::GRD::Exec::Context;
use Amling::Git::GRD::Utils;
use Amling::Git::Utils;

sub handler
{
    my $s0 = shift;
    my $s1 = shift;

    my ($event, $cmd_str);
    if($s0 =~ /^hooks-add ([^ ]+) (.*)$/)
    {
        $event = $1;
        $cmd_str = $2;
    }
    else
    {
        return undef;
    }

    if(!Amling::Git::GRD::Exec::Context::is_event($event))
    {
        return undef;
    }

    my $parse = Amling::Git::GRD::Command::parse($cmd_str, $s1);
    if(!defined($parse))
    {
        return undef;
    }
    my $cmd = $parse->[0];
    $s1 = $parse->[1];

    return [__PACKAGE__->new($event, $cmd), $s1];
}

sub new
{
    my $class = shift;
    my $event = shift;
    my $cmd = shift;

    my $self =
    {
        'event' => $event,
        'cmd' => $cmd,
    };

    bless $self, $class;

    return $self;
}

sub str
{
    my $self = shift;
    my $event = $self->{'event'};
    my $cmd = $self->{'cmd'};
    return "hooks-add $event " . $cmd->str();
}

sub execute
{
    my $self = shift;
    my $ctx = shift;

    my $event = $self->{'event'};
    my $cmd = $self->{'cmd'};

    push @{$ctx->get_hooks_stack()->[-1]->{$event} ||= []}, $cmd;
}

Amling::Git::GRD::Command::add_command(\&handler);

1;
