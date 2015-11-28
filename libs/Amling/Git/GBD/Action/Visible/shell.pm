package Amling::Git::GBD::Action::Visible::shell;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;
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

        my $clazz = "Amling::Git::GBD::Action::Visible::$action_name";
        my $clazz_file = $clazz;
        $clazz_file =~ s@::@/@g;
        $clazz_file .= '.pm';
        require $clazz_file;
        my $action = $clazz->new();

        $action->configure(\@_);
        $state = $action->execute($state);
    }

    return $state;
}

1;
