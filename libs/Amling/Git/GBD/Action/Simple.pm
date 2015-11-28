package Amling::Git::GBD::Action::Simple;

use strict;
use warnings;

use Getopt::Long;

sub new
{
    my $class = shift;

    my $commits = {};

    my $self =
    {
        $class->defaults(),
    };

    bless $self, $class;

    return $self;
}

sub configure
{
    my $self = shift;
    my $args = shift;

    my %options = $self->options();
    my @options;
    for my $k (keys(%options))
    {
        push @options, $k => \($self->{$options{$k}});
    }

    my $p = Getopt::Long::Parser->new();
    $p->configure('require_order');
    $p->getoptionsfromarray($args, @options) || die;

    $self->validate();
}

sub defaults
{
    return
    (
    );
}

sub options
{
    return
    (
    );
}

sub validate
{
}

1;
