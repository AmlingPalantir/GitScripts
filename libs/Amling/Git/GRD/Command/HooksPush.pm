package Amling::Git::GRD::Command::HooksPush;

use strict;
use warnings;

use Amling::Git::GRD::Command::Simple;
use Amling::Git::GRD::Command;
use Amling::Git::Utils;

use base 'Amling::Git::GRD::Command::Simple';

sub name
{
    return "hooks-push";
}

sub args
{
    return 0;
}

sub execute_simple
{
    my $self = shift;
    my $ctx = shift;

    push @{$ctx->get_hooks_stack()}, {};
}

Amling::Git::GRD::Command::add_command(sub { return __PACKAGE__->handler(@_) });

1;
