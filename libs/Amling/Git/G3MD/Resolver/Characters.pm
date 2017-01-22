package Amling::Git::G3MD::Resolver::Characters;

use strict;
use warnings;

use Amling::Git::G3MD::Parser;
use Amling::Git::G3MD::Resolver::Simple;
use Amling::Git::G3MD::Resolver::Git;
use Amling::Git::G3MD::Resolver;
use File::Temp ('tempfile');

use base ('Amling::Git::G3MD::Resolver::Simple');

sub names
{
    return ['character', 'char', 'c'];
}

sub description
{
    return 'recursively resolve by character.';
}

sub handle_simple
{
    my $class = shift;
    my $conflict = shift;
    my ($lhs_title, $lhs_lines, $mhs_title, $mhs_lines, $rhs_title, $rhs_lines) = @$conflict;

    for my $r (\$lhs_lines, \$mhs_lines, \$rhs_lines)
    {
        my $new = [];
        for my $line (@$$r)
        {
            for my $c (split('', $line))
            {
                push @$new, uc(unpack("H*", $c)) . ": $c";
            }
            push @$new, '0A: \n';
        }
        $$r = $new;
    }

    my $blocks = Amling::Git::G3MD::Resolver::Git->handle_simple([$lhs_title, $lhs_lines, $mhs_title, $mhs_lines, $rhs_title, $rhs_lines]);
    my $lines = Amling::Git::G3MD::Resolver::resolve_blocks($blocks);
    my $blocks2 = Amling::Git::G3MD::Parser::parse_3way($lines);

    my $blocks3 = [];
    my $pending = ['', '', ''];
    my $flush = sub
    {
        my $empty = 1;
        for my $i (0, 1, 2)
        {
            if($pending->[$i] ne '')
            {
                $empty = 0;
                last;
            }
        }
        return if($empty);
        my $conflict = 0;
        for my $i (0, 1, 2)
        {
            die unless($pending->[$i] =~ s/\n$//);
            $conflict = 1 if($pending->[$i] =~ /\n/);
        }
        if(!$conflict && $pending->[0] eq $pending->[1] && $pending->[1] eq $pending->[2])
        {
            push @$blocks3, ['LINE', $pending->[0]];
        }
        else
        {
            # We sort of have a choice here.  The recursive resolve punted (!).  We
            # choose to dishonor it and represent the conflict.  This means people
            # who want to punt must punt twice, but people that just want to punt
            # w/in the recursive resolve can do so without forcing a punt here.

            push @$blocks3,
            [
                'CONFLICT',
                $lhs_title,
                [split(/\n/, $pending->[0])],
                $mhs_title,
                [split(/\n/, $pending->[1])],
                $rhs_title,
                [split(/\n/, $pending->[2])],
            ];
        }

        $pending = ['', '', ''];
    };
    for my $block (@$blocks2)
    {
        my $type = $block->[0];

        if(0)
        {
        }
        elsif($type eq 'LINE')
        {
            if($block->[1] =~ /^([0-9A-F]{2}): /)
            {
                my $c = pack("H*", lc($1));
                $pending->[0] .= $c;
                $pending->[1] .= $c;
                $pending->[2] .= $c;
                $flush->() if($c eq "\n");
            }
            else
            {
                die "Nonsense line from result of recursive merge: " . $block->[1];
            }
        }
        elsif($type eq 'CONFLICT')
        {
            my $conflict = [@$block];
            shift @$conflict;

            for my $i (0, 1, 2)
            {
                for my $line (@{$conflict->[2 * $i + 1]})
                {
                    if($line =~ /^([0-9A-F]{2}): /)
                    {
                        $pending->[$i] .= pack("H*", lc($1));
                    }
                    else
                    {
                        die "Nonsense line from result of recursive merge: $line";
                    }
                }
            }
        }
        else
        {
            die;
        }
    }
    $flush->();

    return $blocks3;
}

Amling::Git::G3MD::Resolver::add_resolver(__PACKAGE__);

1;
