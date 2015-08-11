package Amling::Git::GRD::Command::HooksPop;

use strict;
use warnings;

use Amling::Git::GRD::Command::Simple;
use Amling::Git::GRD::Command;
use Amling::Git::Utils;

use base 'Amling::Git::GRD::Command::Simple';

sub name
{
    return "hooks-pop";
}

sub args
{
    return 0;
}

sub execute_simple
{
    my $self = shift;
    my $ctx = shift;

    my $stack = $ctx->get_hooks_stack();
    my $popped = pop @$stack;
    if(!@$stack)
    {
        die "Empty hooks stack popped";
    }
}

Amling::Git::GRD::Command::add_command(sub { return __PACKAGE__->handler(@_) });

1;
