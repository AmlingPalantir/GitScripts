package Amling::Git::GBD::Action::LoadSave;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;
use Amling::Git::Utils;

use base ('Amling::Git::GBD::Action::Simple');

sub defaults
{
    return
    (
        'FILE' => undef,
        'NAME' => undef,
    );
}

sub options
{
    return
    (
        'file=s' => 'FILE',
        'name=s' => 'NAME',
    );
}

sub validate
{
    my $self = shift;

    my $file_option = $self->{'FILE'};
    my $name_option = $self->{'NAME'};

    my $file;
    if(defined($file_option))
    {
        if(defined($name_option))
        {
            die "Cannot specify both --file and --name";
        }
        $file = $file_option;
    }
    else
    {
        if(!defined($name_option))
        {
            $name_option = 'default';
        }
        $file = Amling::Git::Utils::find_root() . "/.git/gbd/$name_option.state";
    }

    $self->{'FILE'} = $file;
    delete $self->{'NAME'};
}

sub execute
{
    my $self = shift;
    my $state = shift;
    my $file = $self->{'FILE'};

    return $self->execute2($state, $file);
}

1;
