package Amling::Git::G3MDNG::Command::Split;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseReplace;

use base ('Amling::Git::G3MDNG::Command::BaseReplace');

sub args_regex
{
    return qr/(-?\d+)(?:\s+(-?\d+)\s+(-?\d+))?/;
}

sub handle3
{
    my $this = shift;
    my $rest = shift;
    my $lhs_split = shift;
    my $mhs_split = shift;
    my $rhs_split = shift;

    my ($lhs_title, $lhs_chunks, $mhs_title, $mhs_chunks, $rhs_title, $rhs_chunks) = @$rest;

    $mhs_split = $lhs_split unless(defined($mhs_split));
    $rhs_split = $lhs_split unless(defined($rhs_split));

    my $lhs_len = scalar(@$lhs_chunks);
    my $mhs_len = scalar(@$mhs_chunks);
    my $rhs_len = scalar(@$rhs_chunks);

    $lhs_split = $lhs_len - $1 if($lhs_split =~ /^-(\d+)$/);
    $mhs_split = $mhs_len - $1 if($mhs_split =~ /^-(\d+)$/);
    $rhs_split = $rhs_len - $1 if($rhs_split =~ /^-(\d+)$/);

    return undef unless(0 <= $lhs_split && $lhs_split <= $lhs_len);
    return undef unless(0 <= $mhs_split && $mhs_split <= $mhs_len);
    return undef unless(0 <= $rhs_split && $rhs_split <= $rhs_len);

    return
    [
        [
            'CONFLICT',
            $lhs_title,
            [@$lhs_chunks[0..($lhs_split - 1)]],
            $mhs_title,
            [@$mhs_chunks[0..($mhs_split - 1)]],
            $rhs_title,
            [@$rhs_chunks[0..($rhs_split - 1)]],
        ],
        [
            'CONFLICT',
            $lhs_title,
            [@$lhs_chunks[$lhs_split..$#$lhs_chunks]],
            $mhs_title,
            [@$mhs_chunks[$mhs_split..$#$mhs_chunks]],
            $rhs_title,
            [@$rhs_chunks[$rhs_split..$#$rhs_chunks]],
        ],
    ];
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['sp', 'split']));

1;
