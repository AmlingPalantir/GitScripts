package Amling::Git::GBD::Action::WithStatus;

use strict;
use warnings;

use Amling::Git::GBD::Action::Simple;

use base ('Amling::Git::GBD::Action::Simple');

sub defaults
{
    return
    (
        'STRATEGY' => 'min-range',
        'BEFORE' => 'before',
        'AFTER' => 'after',
        'WEIGHT' => '1',
    );
}

sub options
{
    return
    (
        'strategy=s' => 'STRATEGY',
        'before=s' => 'BEFORE',
        'after=s' => 'AFTER',
        'weight=s' => 'WEIGHT',
    );
}

sub execute
{
    my $self = shift;
    my $state = shift;
    my $strategy_name = $self->{'STRATEGY'};
    my $before = $self->{'BEFORE'};
    my $after = $self->{'AFTER'};
    my $weight = $self->{'WEIGHT'};

    my $clazz = "Amling::Git::GBD::Strategy::$strategy_name";
    my $clazz_file = $clazz;
    $clazz_file =~ s@::@/@g;
    $clazz_file .= '.pm';
    require $clazz_file;

    my $result = $clazz->compute($state, $before, $after, $weight);

    return $self->execute2($state, $result);
}

1;
