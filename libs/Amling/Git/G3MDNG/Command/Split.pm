package Amling::Git::G3MDNG::Command::Split;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseSplit;

use base ('Amling::Git::G3MDNG::Command::BaseSplit');

sub compute_len
{
    my $this = shift;
    my $chunks = shift;

    return scalar(@$chunks);
}

sub split_chunks
{
    my $this = shift;
    my $chunks = shift;
    my $split = shift;

    my $chunks2a = [@$chunks[0..($split - 1)]];
    my $chunks2b = [@$chunks[$split..$#$chunks]];

    return ($chunks2a, $chunks2b);
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['split', 'sp']));

1;
