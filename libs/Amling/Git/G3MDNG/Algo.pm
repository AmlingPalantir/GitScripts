package Amling::Git::G3MDNG::Algo;

use strict;
use warnings;

use Text::Diff3;

sub diff3_blocks
{
    my $blocks = shift;

    my $new_blocks = [];
    for my $block (@$blocks)
    {
        my ($type, @rest) = @$block;

        if(0)
        {
        }
        elsif($type eq 'RESOLVED')
        {
            my ($chunk) = @rest;
            push @$new_blocks, ['RESOLVED', $chunk];
        }
        elsif($type eq 'CONFLICT')
        {
            my ($lhs_chunks, $mhs_chunks, $rhs_chunks) = @rest;
            push @$new_blocks, @{diff3($lhs_chunks, $mhs_chunks, $rhs_chunks)};
        }
        else
        {
            die;
        }
    }

    if(!@$new_blocks)
    {
        # we leave as an all-empty conflict to avoid trying to do an empty
        # splice (!)
        return
        [
            [
                'CONFLICT',
                [],
                [],
                [],
            ],
        ];
    }

    return $new_blocks;
}

sub diff3
{
    my $lhs_chunks = shift;
    my $mhs_chunks = shift;
    my $rhs_chunks = shift;

    my $r = Text::Diff3::diff3($lhs_chunks, $mhs_chunks, $rhs_chunks);

    my @replaced_blocks;

    my $lhs_pos = 0;
    my $mhs_pos = 0;
    my $rhs_pos = 0;
    my $do_match = sub
    {
        my $lhs_end = shift;
        my $mhs_end = shift;
        my $rhs_end = shift;
        #print STDERR "match [$lhs_pos, $lhs_end) [$mhs_pos, $mhs_end) [$rhs_pos, $rhs_end)\n";

        my $n = $lhs_end - $lhs_pos;
        die unless($n >= 0);
        die unless($n == $mhs_end - $mhs_pos);
        die unless($n == $rhs_end - $rhs_pos);

        for(my $i = 0; $i < $n; ++$i)
        {
            my $lhs_chunk = $lhs_chunks->[$lhs_pos + $i];
            my $mhs_chunk = $mhs_chunks->[$mhs_pos + $i];
            my $rhs_chunk = $rhs_chunks->[$rhs_pos + $i];
            die unless($lhs_chunk eq $mhs_chunk);
            die unless($mhs_chunk eq $rhs_chunk);

            push @replaced_blocks,
            [
                'RESOLVED',
                $lhs_chunk,
            ];
        }
    };

    for my $e (@$r)
    {
        my ($type, $lhs_start, $lhs_end, $rhs_start, $rhs_end, $mhs_start, $mhs_end) = @$e;
        $do_match->($lhs_start - 1, $mhs_start - 1, $rhs_start - 1);
        push @replaced_blocks,
        [
            'CONFLICT',
            [map { $lhs_chunks->[$_ - 1] } ($lhs_start..$lhs_end)],
            [map { $mhs_chunks->[$_ - 1] } ($mhs_start..$mhs_end)],
            [map { $rhs_chunks->[$_ - 1] } ($rhs_start..$rhs_end)],
        ];

        $lhs_pos = $lhs_end;
        $mhs_pos = $mhs_end;
        $rhs_pos = $rhs_end;
    }
    $do_match->(scalar(@$lhs_chunks), scalar(@$mhs_chunks), scalar(@$rhs_chunks));

    return \@replaced_blocks;
}

1;
