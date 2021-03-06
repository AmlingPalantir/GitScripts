package Amling::Git::G3MDNG::Memory;

use strict;
use warnings;

use Amling::Git::G3MDNG::Utils;
use Digest;
use File::Basename ('dirname');
use File::Path ('make_path');
use JSON;

my $json = JSON->new();
$json->pretty(1);
$json->allow_nonref();

my $hash = \&Amling::Git::G3MDNG::Utils::hash;

sub apply
{
    my $this = shift;
    my $state = shift;

    APPLY:
    while(1)
    {
        my $blocks = $state->blocks();

        my $blocks_hash = $hash->($blocks);
        for my $old_blocks (@{$state->old_blockses()})
        {
            if($blocks_hash eq $hash->($old_blocks))
            {
                print "Current state matches a previous state, refusing to apply memory!\n";
                return;
            }
        }

        my $in_hashes = {};
        for my $block (@$blocks)
        {
            $in_hashes->{$hash->($block)} = 1;
        }

        my $edits = {};
        for my $edit (@{$state->memory_edits()})
        {
            for my $in_block (@{$edit->{'IN'}})
            {
                if($in_hashes->{$hash->($in_block)})
                {
                    $edits->{$hash->($edit)} = $edit;
                    last;
                }
            }
        }

        for my $in_hash (sort(keys(%$in_hashes)))
        {
            for my $edit (@{$this->search($in_hash)})
            {
                $edits->{$hash->($edit)} = $edit;
            }
        }

        for my $edit_hash (sort(keys(%$edits)))
        {
            my $edit = $edits->{$edit_hash};
            my $in_blocks = $edit->{'IN'};
            my $out_blocks = $edit->{'OUT'};
            my $desc = $edit->{'DESC'};
            next if($hash->($in_blocks) eq $hash->($out_blocks));
            my $len = @$in_blocks;
            EDIT_POS:
            for(my $i = 0; $i + $len <= @$blocks; ++$i)
            {
                for(my $j = 0; $j < $len; ++$j)
                {
                    if($hash->($blocks->[$i + $j]) ne $hash->($in_blocks->[$j]))
                    {
                        next EDIT_POS;
                    }
                }
                $state->splice($i, $i + $len, $out_blocks, "memorized $desc", 0);
                next APPLY;
            }
        }

        return;
    }
}

sub search
{
    my $this = shift;
    my $in_hash = shift;

    return [map { $this->load_raw("edits/$_") } @{$this->list_raw("links/$in_hash")}];
}

sub save
{
    my $this = shift;
    my $edit = shift;

    $edit =
    {
        'IN' => $edit->{'IN'},
        'OUT' => $edit->{'OUT'},
        'DESC' => $edit->{'DESC'},
    };

    my $edit_hash = $hash->($edit);
    $this->save_raw("edits/$edit_hash", $edit);

    for my $in_block (@{$edit->{'IN'}})
    {
        my $in_hash = $hash->($in_block);
        $this->save_raw("links/$in_hash/$edit_hash", 1);
    }
}

sub rel
{
    my $this = shift;
    my $file = shift;

    return $ENV{'HOME'} . "/.g3mdng/memory/$file";
}

sub save_raw
{
    my $this = shift;
    my $file = shift;
    my $data = shift;

    $file = $this->rel($file);
    return if(-f $file);

    my $tmp_file = $this->rel('.tmp/tmp-' . rand());

    make_path(dirname($tmp_file));
    open(my $fh, '>', $tmp_file) || die "Could not open $tmp_file: $!";
    print $fh $json->encode($data);
    close($fh) || die "Could not close $tmp_file: $!";

    make_path(dirname($file));
    return if(rename $tmp_file, $file);

    unlink $tmp_file;

    return if(-f $file);

    die "Could not create $file?";
}

sub list_raw
{
    my $this = shift;
    my $dir = shift;

    $dir = $this->rel($dir);

    return [] unless(-d $dir);

    opendir(my $fh, $dir) || die "Could not openddir $dir: $!";
    my @ret;
    while(my $ent = readdir($fh))
    {
        next if($ent eq '.' || $ent eq '..');
        push @ret, $ent;
    }
    closedir($fh) || die "Could not openddir $dir: $!";
    @ret = sort @ret;
    return [@ret];
}

sub load_raw
{
    my $this = shift;
    my $file = shift;

    $file = $this->rel($file);

    return $json->decode(join('', @{Amling::Git::Utils::slurp_raw($file)}));
}

1;
