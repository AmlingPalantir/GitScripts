package Amling::Git::GRD::Utils;

use strict;
use warnings;

use Amling::Git::Utils;

sub run_shell
{
    my $first_shell = shift;
    my $allow_index = shift;
    my $allow_wtree = shift;
    my $env = shift || {};

    my $shell = $ENV{'SHELL'} || '/bin/sh';
    my $grd_level = ($ENV{'GRD_LEVEL'} || 0);

    EDITLOOP:
    while(1)
    {
        if($first_shell)
        {
            my $grd_level2 = $grd_level + 1;
            print "GRD level: $grd_level2\n";
            _system_with_env([$shell], (map { ("GRD_$_", $env->{$_}) } keys(%$env)), 'GRD_LEVEL', $grd_level2);
        }
        else
        {
            $first_shell = 1;
        }

        my $fail;
        my ($dirtyness, $message) = Amling::Git::Utils::get_dirtyness();
        if(!$allow_index && $dirtyness >= 1)
        {
            $fail = $message;
        }
        if(!$allow_wtree && $dirtyness >= 2)
        {
            $fail = $message;
        }

        if(!$fail)
        {
            return;
        }

        # TODO: extract menu util
        while(1)
        {
            print "$fail\n";
            print "What should I do?\n";
            print "s - run a shell\n";
            print "q - abort entire rebase\n";
            print "> ";
            my $ans = <>;
            chomp $ans;

            if($ans eq "q")
            {
                print "Giving up.\n";
                exit 1;
            }
            if($ans eq "s")
            {
                next EDITLOOP;
            }

            print "Not an option: $ans\n";
        }
    }
}

sub escape_msg
{
    my $msg = shift;

    $msg =~ s/\\/\\\\/g;
    $msg =~ s/\n/\\n/g;
    $msg =~ s/#/\\H/g;

    return $msg;
}

sub unescape_msg
{
    my $msg = shift;

    $msg =~ s/\\H/#/g;
    $msg =~ s/\\n/\n/g;
    $msg =~ s/\\\\/\\/g;

    return $msg;
}

sub _system_with_env
{
    my $cmd = shift;
    if(!@_)
    {
        system(@$cmd);
        return;
    }

    my $key = shift;
    my $value = shift;

    local $ENV{$key} = $value;
    _system_with_env($cmd, @_);
}

1;
