package Amling::Git::GRD::Command::Verify;

use strict;
use warnings;

use Amling::Git::GRD::Command::Simple;
use Amling::Git::GRD::Command;
use Amling::Git::GRD::Utils;

use base 'Amling::Git::GRD::Command::Simple';

sub extended_handler
{
    my $s0 = shift;
    my $s1 = shift;

    my $cmd;
    if($s0 =~ /^verify (.+)$/)
    {
        $cmd = $1;
    }
    else
    {
        return undef;
    }

    return [__PACKAGE__->new($cmd), $s1];
}

sub name
{
    return "verify";
}

sub args
{
    return -1;
}

sub execute_simple
{
    my $self = shift;
    my $ctx = shift;
    my $cmd = shift;

    $ctx->materialize_head();

    print "Verifying: $cmd\n";
    my $ret = system('/bin/sh', '-c', $cmd);
    if($ret)
    {
        my $failure;
        if($? == -1)
        {
            $failure = "failed to execute";
        }
        elsif($? & 127)
        {
            $failure = "signal " . ($? & 127);
        }
        else
        {
            $failure = "exit value " . ($? >> 8);
        }
        print "Verification failed: $failure, dropping into shell...\n";
        Amling::Git::GRD::Utils::run_shell(1, 0, 0);
        print "Shell complete, continuing...\n";
    }
    else
    {
        Amling::Git::GRD::Utils::run_shell(0, 0, 0);
        print "Verification complete, continuing...\n";
    }

    $ctx->uptake_head();
}

# nope: Amling::Git::GRD::Command::add_command(sub { return __PACKAGE__->handler(@_) });
Amling::Git::GRD::Command::add_command(\&extended_handler);

1;
