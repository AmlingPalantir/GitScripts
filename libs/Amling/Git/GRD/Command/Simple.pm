package Amling::Git::GRD::Command::Simple;

use strict;
use warnings;

sub handler
{
    my $class = shift;
    my $s0 = shift;
    my $s1 = shift;

    $s0 =~ s/\#.*$//;
    my @s0 = split(/ /, $s0);

    my $s00 = shift @s0;
    if($s00 ne $class->name())
    {
        return undef;
    }

    if(defined($class->min_args()) && @s0 < $class->min_args())
    {
        die "Not enough arguments for $s00";
    }

    if(defined($class->max_args()) && @s0 > $class->max_args())
    {
        die "Too many arguments for $s00";
    }

    return [$class->new(@s0), $s1];
}

sub new
{
    my $class = shift;

    my $self =
    {
        'args' => \@_,
    };

    bless $self, $class;

    return $self;
}

sub execute
{
    my $self = shift;
    my $ctx = shift;

    $self->execute_simple($ctx, @{$self->{'args'}});
}

sub str
{
    my $self = shift;

    return $self->str_simple(@{$self->{'args'}});
}

sub str_simple
{
    my $self = shift;

    return join(" ", $self->name(), @_);
}

sub min_args
{
    my $class = shift;

    return $class->args();
}

sub max_args
{
    my $class = shift;

    return $class->args();
}

1;
