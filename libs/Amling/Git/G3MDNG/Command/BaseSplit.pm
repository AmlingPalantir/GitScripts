package Amling::Git::G3MDNG::Command::BaseSplit;

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

    my $lhs_len = $this->compute_len($lhs_chunks);
    my $mhs_len = $this->compute_len($mhs_chunks);
    my $rhs_len = $this->compute_len($rhs_chunks);

    $lhs_split = $lhs_len - $1 if($lhs_split =~ /^-(\d+)$/);
    $mhs_split = $mhs_len - $1 if($mhs_split =~ /^-(\d+)$/);
    $rhs_split = $rhs_len - $1 if($rhs_split =~ /^-(\d+)$/);

    return undef unless(0 <= $lhs_split && $lhs_split <= $lhs_len);
    return undef unless(0 <= $mhs_split && $mhs_split <= $mhs_len);
    return undef unless(0 <= $rhs_split && $rhs_split <= $rhs_len);

    my ($lhs_chunks2a, $lhs_chunks2b) = $this->split_chunks($lhs_chunks, $lhs_split);
    my ($mhs_chunks2a, $mhs_chunks2b) = $this->split_chunks($mhs_chunks, $mhs_split);
    my ($rhs_chunks2a, $rhs_chunks2b) = $this->split_chunks($rhs_chunks, $rhs_split);

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

1;
