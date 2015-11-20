package Amling::Git::GRD::Command::Branch;

use strict;
use warnings;

use Amling::Git::GRD::Command::Simple;
use Amling::Git::GRD::Command;
use Amling::Git::GRD::Exec::Context;
use Amling::Git::Utils;

use base 'Amling::Git::GRD::Command::Simple';

sub name
{
    return "branch";
}

sub args
{
    return 1;
}

sub execute_simple
{
    my $self = shift;
    my $ctx = shift;
    my $branch = shift;

    $ctx->run_hooks('pre-branch', {'BRANCH' => $branch});
    $ctx->get('branches', {})->{$branch} = $ctx->get_head();
}

Amling::Git::GRD::Command::add_command(sub { return __PACKAGE__->handler(@_) });
Amling::Git::GRD::Exec::Context::add_event('pre-branch');

1;
