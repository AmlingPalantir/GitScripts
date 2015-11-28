package Amling::Git::GBD::Strategy::min_range;

use strict;
use warnings;

sub compute
{
    my $clazz = shift;
    my $state = shift;
    my $before_label = shift;
    my $after_label = shift;
    my $weight_code = shift;

    my %befores = map { $_ => 1 } $state->commits_for_label($before_label);
    my %afters = map { $_ => 1 } $state->commits_for_label($after_label);

    # step 1: decide which befores can provide assumed-before evidence for which afters
    my %before_afters_contained;
    for my $before (keys(%befores))
    {
        my $afters_contained = $before_afters_contained{$before} = {};
        my @q = ($before);
        my %already;
        while(@q)
        {
            my $commit = shift @q;
            next if($already{$commit});
            $already{$commit} = 1;

            if($afters{$commit})
            {
                $afters_contained->{$commit} = 1;
            }

            push @q, @{$state->get_commit($commit)->{'parents'}};
        }
    }

    # step 2: look over after candidates
    my @candidates;
    for my $after (keys(%afters))
    {
        # take all befores which do not have $after as an ancestor and build
        # %assumed_befores from their ancestors
        my %assumed_befores;
        {
            my @q;
            for my $before (keys(%befores))
            {
                next if($before_afters_contained{$before}->{$after});
                push @q, $before;
            }
            my %already;
            while(@q)
            {
                my $commit = shift @q;
                next if($already{$commit});
                $already{$commit} = 1;

                $assumed_befores{$commit} = 1;

                push @q, @{$state->get_commit($commit)->{'parents'}};
            }
        }

        # now walk back from $after looking for ... stuff
        my %known_blocks;
        my %assumed_blocks;
        {
            my $ko = 0;
            my @q = ($after);
            my %already;
            while(@q)
            {
                my $commit = shift @q;
                next if($already{$commit});
                $already{$commit} = 1;

                if($befores{$commit})
                {
                    $known_blocks{$commit} = 1;
                    next;
                }
                if($assumed_befores{$commit})
                {
                    $assumed_blocks{$commit} = 1;
                    next;
                }
                if($afters{$commit} && $commit ne $after)
                {
                    $ko = 1;
                    last;
                }

                push @q, @{$state->get_commit($commit)->{'parents'}};
            }
            next if($ko);
        }
        my @blocks = (keys(%known_blocks), keys(%assumed_blocks));
        my $delta_weight = $state->delta_weight($weight_code, [$after], [@blocks]);
        my $delta_count = $state->delta_weight('1', [$after], [@blocks]);

        push @candidates, [$after, \%known_blocks, \%assumed_blocks, $delta_weight, $delta_count];
    }

    die "No candidate for $after_label?" unless(@candidates);

    # "find" the best
    my $sort_cb = sub
    {
        my ($a_after, $a_known_blocks, $a_assumed_blocks, $a_delta_weight, $a_delta_count) = @$a;
        my ($b_after, $b_known_blocks, $b_assumed_blocks, $b_delta_weight, $b_delta_count) = @$b;

        my $r = 0;

        # most important: weight
        $r ||= ($a_delta_weight <=> $b_delta_weight);

        # but zero weight does not mean we're done!  check assumed blocks
        $r ||= (scalar(keys(%$a_assumed_blocks)) <=> scalar(keys(%$b_assumed_blocks)));

        # actually, even no assumed blocks and zero weight is not enough since
        # there can be zero weight commits!
        $r ||= $a_delta_count <=> $b_delta_count;

        return $r;
    };
    @candidates = sort { $sort_cb->() } @candidates;

    my ($after, $known_blocks, $assumed_blocks, $delta_weight, $delta_count) = @{$candidates[0]};

    my @status;
    my $next;
    if($delta_count == 1)
    {
        # down to a single commit, maybe done?
        if(%$assumed_blocks)
        {
            # not quite, some exit from the block is still merely assumed
            ($next) = keys(%$assumed_blocks);
            push @status, "Forced to test assumed $before_label.";
        }
        else
        {
            # done!
            $next = $after;
            push @status, "Done.";
        }
    }
    else
    {
        # the common case -- we have a nontrivial window blah blah blah
        my $weight_code2;
        my $delta_weight2;
        if($delta_weight != 0)
        {
            $weight_code2 = $weight_code;
            $delta_weight2 = $delta_weight;
        }
        else
        {
            $weight_code2 = '1';
            $delta_weight2 = $delta_count;
        }
        $next = choose_next($state, $weight_code2, $after, [keys(%$known_blocks), keys(%$assumed_blocks)], $delta_weight2);
    }

    return
    {
        'RANGE' =>
        {
            'PLUS' => $after,
            'MINUS' => [sort(keys(%$known_blocks), keys(%$assumed_blocks))],
            'WEIGHT' => $delta_weight,
            'COUNT' => $delta_count,
        },
        'NEXT' => $next,
        'STATUS' => [@status],
    };
}

sub choose_next
{
    my $state = shift;
    my $weight_code = shift;
    my $after = shift;
    my $blocks = shift;
    my $delta_weight = shift;

    my $target_weight = $delta_weight / 2;
    my %blocks = map { $_ => 1 } @$blocks;

    # Look over parents.  If none have within-window weight higher than target
    # then we're sort of doomed (the only cut point is $after itself but we
    # can't test that).  If this happens we take the parent with the highest
    # weight (it's the most we can guarantee eliminating in one test).
    my $best_parent = undef;
    my $best_weight = 0;
    my $ok = 0;
    for my $parent (@{$state->get_commit($after)->{'parents'}})
    {
        next if($blocks{$parent});
        my $weight = $state->delta_weight($weight_code, [$parent], $blocks);
        if($weight > $best_weight)
        {
            $best_parent = $parent;
            $best_weight = $weight;
        }
        if($weight >= $target_weight / 2)
        {
            # This guarantees the cut point will not be $after, we can proceed
            # to main case.
            $ok = 1;
            last;
        }
    }

    if(!$ok)
    {
        die unless($best_parent); # this would have been a one commit window
        return $best_parent;
    }

    # Great, now look for a cut point for real.
    my %too_low = %blocks;
    my $too_high = $after;
    while(1)
    {
        my @middle;
        my @q = ($too_high);
        my %already = %too_low;
        while(@q)
        {
            my $commit = shift @q;
            next if($already{$commit});
            $already{$commit} = 1;

            if($commit ne $too_high)
            {
                push @middle, $commit;
            }

            push @q, @{$state->get_commit($commit)->{'parents'}};
        }

        if(!@middle)
        {
            die if($too_high eq $after); # this should have been caught above
            return $too_high;
        }

        @middle = map { $_->[0] } sort { $a->[1] <=> $b->[1] } map { [$_, rand()] } @middle;
        my $test = $middle[0];
        my $test_weight = $state->delta_weight($weight_code, [$test], $blocks);

        if($test_weight >= $target_weight)
        {
            $too_high = $test;
        }
        else
        {
            $too_low{$test} = 1;
        }
    }
}

1;
