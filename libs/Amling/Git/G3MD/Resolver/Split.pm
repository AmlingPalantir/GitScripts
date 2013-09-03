package Amling::Git::G3MD::Resolver::Split;

use strict;
use warnings;

sub _names
{
    return ['sp', 'split'];
}

sub handle
{
    my $class = shift;
    my $line = shift;
    my $conflict = shift;

    for my $name (@{$class->_names()})
    {
        if($line =~ /^\s*\Q$name\E\s+(\d+)\s+(\d+)\s+(\d+)\s*$/)
        {
            return $class->_handle2($1, $2, $3, $conflict);
        }
    }

    return undef;
}

sub _handle2
{
    my $class = shift;
    my $lhs_depth = shift;
    my $mhs_depth = shift;
    my $rhs_depth = shift;
    my $conflict = shift;

    my ($lhs_title, $lhs_lines, $mhs_title, $mhs_lines, $rhs_title, $rhs_lines) = @$conflict;

    my @lhs_lines1;
    my @lhs_lines2;
    my @mhs_lines1;
    my @mhs_lines2;
    my @rhs_lines1;
    my @rhs_lines2;

    for my $tuple ([\@lhs_lines1, \@lhs_lines2, $lhs_lines, $lhs_depth], [\@mhs_lines1, \@mhs_lines2, $mhs_lines, $mhs_depth], [\@rhs_lines1, \@rhs_lines2, $rhs_lines, $rhs_depth])
    {
        my ($lines1, $lines2, $lines, $depth) = @$tuple;

        for(my $i = 0; $i < @$lines; ++$i)
        {
            push @{$i < $depth ? $lines1 : $lines2}, $lines->[$i];
        }
    }

    my @ret;

    push @ret,
    [
        'CONFLICT',
        $lhs_title,
        \@lhs_lines1,
        $mhs_title,
        \@mhs_lines1,
        $rhs_title,
        \@rhs_lines1,
    ];
    push @ret,
    [
        'CONFLICT',
        $lhs_title,
        \@lhs_lines2,
        $mhs_title,
        \@mhs_lines2,
        $rhs_title,
        \@rhs_lines2,
    ];

    return Amling::Git::G3MD::Resolver::Git->resolve_blocks(\@ret);
}

Amling::Git::G3MD::Resolver::add_resolver(sub { return __PACKAGE__->handle(@_); });

1;