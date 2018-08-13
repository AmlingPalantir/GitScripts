package Amling::Git::G3MDNG::Command::BaseReplace;

use strict;
use warnings;

use Amling::Git::G3MDNG::Command::Base;

use base ('Amling::Git::G3MDNG::Command::Base');

sub handle2
{
    my $this = shift;
    my $state = shift;
    my @match = @_;

    my $block = $state->current_block();

    my ($type, @rest) = @$block;
    return 0 unless($type eq 'CONFLICT');

    my $replaced_blocks = $this->handle3(\@rest, @match);
    return 0 unless($replaced_blocks);

    $state->replace_current($replaced_blocks);
    $state->mark_dirty();

    return 1;
}

1;
