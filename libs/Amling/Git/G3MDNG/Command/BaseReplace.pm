package Amling::Git::G3MDNG::Command::BaseReplace;

use strict;
use warnings;

use Amling::Git::G3MDNG::Algo;
use Amling::Git::G3MDNG::Command::Base;

use base ('Amling::Git::G3MDNG::Command::Base');

sub handle2
{
    my $this = shift;
    my $state = shift;
    my @match = @_;

    my $block = $state->current_block();
    my $pos = $state->current_pos();

    my ($type, @rest) = @$block;
    return 0 unless($type eq 'CONFLICT');

    my $new_blocks = $this->handle3(\@rest, @match);
    return 0 unless($new_blocks);

    my $desc = $this->{'ALIASES'}->[0];
    my $args = $this->args_string(@match);
    if($args ne '')
    {
        $desc .= " $args";
    }

    if(!$state->splice($pos, $pos + 1, $new_blocks, $desc, 1))
    {
        return 1;
    }

    my $newer_blocks = Amling::Git::G3MDNG::Algo::diff3_blocks($new_blocks);

    $state->splice($pos, $pos + @$new_blocks, $newer_blocks, "auto diff3", 1);
    $state->mark_dirty();

    return 1;
}

1;
