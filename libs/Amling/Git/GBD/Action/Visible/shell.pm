package Amling::Git::GBD::Action::Visible::shell;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;
use Amling::Git::GBD::Utils;
use Text::ParseWords;

use base ('Amling::Git::GBD::Action::Simple');

sub execute
{
    my $self = shift;
    my $state = shift;

    while(1)
    {
        print "> ";
        my $line;
        {
            local @ARGV = ();
            $line = <>;
        }
        if(!$line)
        {
            last;
        }
        chomp $line;
        my @args = shellwords($line);
        eval
        {
            $state = interpret($state, @args);
        };
        if($@)
        {
            warn "Failed: $@";
        }
    }

    return $state;
}

sub interpret
{
    my $state = shift;

    while(@_)
    {
        my $action_name = shift;

        my $action_clazz = Amling::Git::GBD::Utils::find_impl('Amling::Git::GBD::Action::Visible', $action_name);
        my $action = $action_clazz->new();

        $action->configure(\@_);

        $state = $action->execute($state);
    }

    return $state;
}

1;
