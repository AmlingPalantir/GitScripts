package Amling::Git::G3MDNG::Command::Characters;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseReplace;

use base ('Amling::Git::G3MDNG::Command::BaseReplace');

sub handle3
{
    my $this = shift;
    my $rest = shift;

    my ($lhs_title, $lhs_chunks, $mhs_title, $mhs_chunks, $rhs_title, $rhs_chunks) = @$rest;

    return
    [
        [
            'CONFLICT',
            $lhs_title,
            [map { split(//, $_) } @$lhs_chunks],
            $mhs_title,
            [map { split(//, $_) } @$mhs_chunks],
            $rhs_title,
            [map { split(//, $_) } @$rhs_chunks],
        ],
    ];
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['characters', 'character', 'chars', 'char', 'c']));

1;
