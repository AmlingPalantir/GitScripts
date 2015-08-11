package Amling::Git::GRD::Command::HooksAdd;

use strict;
use warnings;

use Amling::Git::GRD::Command;
use Amling::Git::GRD::Utils;
use Amling::Git::Utils;

sub handler
{
    my $s = shift;

    my ($event, $cmd_str);
    if($s =~ /^hooks-add ([^ ]+) (.*)$/)
    {
        $event = $1;
        $cmd_str = $2;
    }
    else
    {
        return undef;
    }

    my $cmd = Amling::Git::GRD::Command::parse($cmd_str);
    if(!defined($cmd))
    {
        return undef;
    }

    return __PACKAGE__->new($event, $cmd);
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
