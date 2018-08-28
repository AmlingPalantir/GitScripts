package Amling::Git::G3MDNG::Command::CharacterSplit;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::BaseSplit;

use base ('Amling::Git::G3MDNG::Command::BaseSplit');

sub compute_len
{
    my $this = shift;
    my $chunks = shift;

    my $s = 0;
    $s += length($_) for(@$chunks);
    return $s;
}

sub split_chunks
{
    my $this = shift;
    my $chunks = shift;
    my $split = shift;

    my $chunks2a = [];
    my $chunks2b = [];

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

    return ($chunks2a, $chunks2b);
}

Amling::Git::G3MDNG::Command::add_command(__PACKAGE__->new(['csplit', 'csp', 'cs']));

1;
