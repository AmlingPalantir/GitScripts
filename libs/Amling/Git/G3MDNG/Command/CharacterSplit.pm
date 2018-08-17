package Amling::Git::G3MDNG::Command::CharacterSplit;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseReplace;

use base ('Amling::Git::G3MDNG::Command::BaseReplace');

sub args_regex
{
    return qr/\s(-?\d+)(?:\s+(-?\d+)\s+(-?\d+))?/;
}

sub handle3
{
    my $this = shift;
    my $rest = shift;
    my $lhs_split = shift;
    my $mhs_split = shift;
    my $rhs_split = shift;

    my ($lhs_chunks, $mhs_chunks, $rhs_chunks) = @$rest;

    $mhs_split = $lhs_split unless(defined($mhs_split));
    $rhs_split = $lhs_split unless(defined($rhs_split));

    my $compute_len = sub
    {
        my $chunks = shift;
        my $s = 0;
        $s += length($_) for(@$chunks);
        return $s;
    };

    my $lhs_len = $compute_len->($lhs_chunks);
    my $mhs_len = $compute_len->($mhs_chunks);
    my $rhs_len = $compute_len->($rhs_chunks);

    $lhs_split = $lhs_len - $1 if($lhs_split =~ /^-(\d+)$/);
    $mhs_split = $mhs_len - $1 if($mhs_split =~ /^-(\d+)$/);
    $rhs_split = $rhs_len - $1 if($rhs_split =~ /^-(\d+)$/);

    return undef unless(0 <= $lhs_split && $lhs_split <= $lhs_len);
    return undef unless(0 <= $mhs_split && $mhs_split <= $mhs_len);
    return undef unless(0 <= $rhs_split && $rhs_split <= $rhs_len);

    my $lhs_chunks2a = [];
    my $mhs_chunks2a = [];
    my $rhs_chunks2a = [];
    my $lhs_chunks2b = [];
    my $mhs_chunks2b = [];
    my $rhs_chunks2b = [];

    my $split_chunks = sub
    {
        my $chunks = shift;
        my $split = shift;
        my $chunks2a = shift;
        my $chunks2b = shift;

        my $s = 0;
        for my $chunk (@$chunks)
        {
            my $cut = $split - $s;
            if($cut >= length($chunk))
            {
                push @$chunks2a, $chunk;
            }
            elsif($cut <= 0)
            {
                push @$chunks2b, $chunk;
            }
            else
            {
                push @$chunks2a, substr($chunk, 0, $cut);
                push @$chunks2b, substr($chunk, $cut);
            }

            $s += length($chunk);
        }
    };

    $split_chunks->($lhs_chunks, $lhs_split, $lhs_chunks2a, $lhs_chunks2b);
    $split_chunks->($mhs_chunks, $mhs_split, $mhs_chunks2a, $mhs_chunks2b);
    $split_chunks->($rhs_chunks, $rhs_split, $rhs_chunks2a, $rhs_chunks2b);

    return
    [
        [
            'CONFLICT',
            $lhs_chunks2a,
            $mhs_chunks2a,
            $rhs_chunks2a,
        ],
        [
            'CONFLICT',
            $lhs_chunks2b,
            $mhs_chunks2b,
            $rhs_chunks2b,
        ],
    ];
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['csplit', 'csp', 'cs']));

1;
