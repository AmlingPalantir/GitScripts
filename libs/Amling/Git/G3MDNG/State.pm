package Amling::Git::G3MDNG::State;

use strict;
use warnings;

use Amling::Git::G3MDNG::Utils;

sub new
{
    my $class = shift;
    my $blocks = shift;

    my $this =
    {
        'BLOCKS' => $blocks,
        'UNDO' => [],
        'REDO' => [],
        'POS' => 0,
        'DIRTY' => 1,
    };

    bless $this, $class;

    return $this;
}

sub merge
{
    my $this = shift;
    my $s = shift;
    my $e = shift;

    my $blocks = $this->{'BLOCKS'};

    my $merged_lhs_title = undef;
    my $merged_mhs_title = undef;
    my $merged_rhs_title = undef;
    my $merged_lhs_chunks = [];
    my $merged_mhs_chunks = [];
    my $merged_rhs_chunks = [];
    for(my $i = $s; $i < $e; ++$i)
    {
        my $block = $blocks->[$i];
        my ($type, @rest) = @$block;
        if(0)
        {
        }
        elsif($type eq 'RESOLVED')
        {
            my ($chunk) = @rest;
            push @$merged_lhs_chunks, $chunk;
            push @$merged_mhs_chunks, $chunk;
            push @$merged_rhs_chunks, $chunk;
        }
        elsif($type eq 'CONFLICT')
        {
            my ($lhs_title, $lhs_chunks, $mhs_title, $mhs_chunks, $rhs_title, $rhs_chunks) = @rest;
            $merged_lhs_title = $lhs_title unless(defined($merged_lhs_title));
            $merged_mhs_title = $mhs_title unless(defined($merged_mhs_title));
            $merged_rhs_title = $rhs_title unless(defined($merged_rhs_title));
            push @$merged_lhs_chunks, @$lhs_chunks;
            push @$merged_mhs_chunks, @$mhs_chunks;
            push @$merged_rhs_chunks, @$rhs_chunks;
        }
        else
        {
            die;
        }
    }
    $merged_lhs_title = 'LHS' unless(defined($merged_lhs_title));
    $merged_mhs_title = 'MHS' unless(defined($merged_mhs_title));
    $merged_rhs_title = 'RHS' unless(defined($merged_rhs_title));

    my $merged_block =
    [
        'CONFLICT',
        $merged_lhs_title,
        $merged_lhs_chunks,
        $merged_mhs_title,
        $merged_mhs_chunks,
        $merged_rhs_title,
        $merged_rhs_chunks,
    ];

    $this->splice($s, $e, [$merged_block], 'merge');
}

sub find_conflict
{
    my $this = shift;
    my $dir = shift || 1;
    my $offset = shift || 0;

    my $blocks = $this->{'BLOCKS'};
    my $pos = $this->{'POS'};

    my $n = @$blocks;
    for(my $i = 0; $i < $n; ++$i)
    {
        my $pos2 = ($pos + ($offset + $i) * $dir) % $n;
        if(!defined(Amling::Git::G3MDNG::Utils::auto_resolve_block($blocks->[$pos2])))
        {
            return $pos2;
        }
    }

    return undef;
}

sub require_auto_resolve
{
    my $this = shift;

    my @texts;
    for my $block (@{$this->{'BLOCKS'}})
    {
        my $text = Amling::Git::G3MDNG::Utils::auto_resolve_block($block);
        die unless(defined($text));

        push @texts, $text;
    }

    return join('', @texts);
}

sub mark_dirty
{
    my $this = shift;

    $this->{'DIRTY'} = 1;
}

sub is_dirty
{
    my $this = shift;

    return $this->{'DIRTY'};
}

sub mark_clean
{
    my $this = shift;

    $this->{'DIRTY'} = 0;
}

sub move
{
    my $this = shift;
    my $pos = shift;

    $this->{'POS'} = $pos;
}

sub move_delta
{
    my $this = shift;
    my $delta = shift;

    $this->{'POS'} += $delta;
    $this->{'POS'} %= scalar(@{$this->{'BLOCKS'}});
}

sub current_pos
{
    my $this = shift;

    return $this->{'POS'};
}

sub current_block
{
    my $this = shift;

    return $this->{'BLOCKS'}->[$this->{'POS'}];
}

sub splice
{
    my $this = shift;
    my $s = shift;
    my $e = shift;
    my $new_blocks = shift;
    my $desc = shift;

    # We can't handle this case (e.g.  may leave with no blocks left, nowhere
    # to put cursor!).  If we ever invent deletion (goodness, why) maybe we'll
    # insert an empty block instead or something.
    die unless(@$new_blocks);

    my $blocks = $this->{'BLOCKS'};
    my $pos = $this->{'POS'};

    my $blocks2 = [@$blocks];
    my $old_blocks = [splice @$blocks2, $s, $e - $s, @$new_blocks];

    my $pos2;
    if($pos < $s)
    {
        # we were strictly before the edit, stay where we are
        $pos2 = $pos;
    }
    elsif($pos >= $e)
    {
        # we were strictly after the edit, adjust for edit resize
        $pos2 = $s + scalar(@$new_blocks) + ($pos - $e);
    }
    else
    {
        # we were in the edit itself, for now let's not worry about mapping and
        # just put ourselves at the top of the new blocks
        $pos2 = $s;
    }

    my $edit =
    {
        'IN' => $old_blocks,
        'OUT' => $new_blocks,
        'DESC' => $desc,
        'START' => $s,
    };
    push @{$this->{'UNDO'}}, [$pos, $pos2, $blocks, $edit];
    $this->{'REDO'} = [];

    $this->{'BLOCKS'} = $blocks2;
    $this->{'POS'} = $pos2;

    print "Applied " . describe_edit($edit) . ".\n";
}

sub undo
{
    my $this = shift;

    my $last = pop @{$this->{'UNDO'}};
    return 0 unless($last);

    my ($pos_before, $pos_after, $blocks_before, $edit) = @$last;
    push @{$this->{'REDO'}}, [$pos_before, $pos_after, $this->{'BLOCKS'}, $edit];

    $this->{'POS'} = $pos_before;
    $this->{'BLOCKS'} = $blocks_before;

    print "Undid " . describe_edit($edit) . ".\n";

    return 1;
}

sub redo
{
    my $this = shift;

    my $next = pop @{$this->{'REDO'}};
    return 0 unless($next);

    my ($pos_before, $pos_after, $blocks_after, $edit) = @$next;
    push @{$this->{'UNDO'}}, [$pos_before, $pos_after, $this->{'BLOCKS'}, $edit];

    $this->{'POS'} = $pos_after;
    $this->{'BLOCKS'} = $blocks_after;

    print "Redid " . describe_edit($edit) . ".\n";

    return 1;
}

sub describe_edit
{
    my $edit = shift;

    my $in_blocks = $edit->{'IN'};
    my $out_blocks = $edit->{'IN'};
    my $desc = $edit->{'DESC'};
    my $s = $edit->{'START'};

    return "$desc [$s, " . ($s + scalar(@$in_blocks)) . ") -> [$s, " . ($s + scalar(@$out_blocks)) . ")";
}

1;
