package Amling::Git::G3MD::Resolver;

use strict;
use warnings;

my @resolvers;

sub add_resolver
{
    my $resolver = shift;

    push @resolvers, $resolver;
}

sub map_blocks
{
    my $blocks = shift;
    my $cb = shift;

    my @ret;
    for my $block (@$blocks)
    {
        my $type = $block->[0];
        if(0)
        {
        }
        elsif($type eq 'LINE')
        {
            push @ret, $block;
        }
        elsif($type eq 'CONFLICT')
        {
            my $conflict = [@$block];
            shift @$conflict;

            push @ret, @{$cb->($conflict)};
        }
        else
        {
            die;
        }
    }

    return \@ret;
}

sub resolve_blocks
{
    my $blocks = shift;

    my @lines;
    for my $block (@$blocks)
    {
        my $type = $block->[0];

        if(0)
        {
        }
        elsif($type eq 'LINE')
        {
            push @lines, $block->[1];
        }
        elsif($type eq 'CONFLICT')
        {
            my $conflict = [@$block];
            shift @$conflict;

            push @lines, @{resolve_conflict($conflict)};
        }
        else
        {
            die;
        }
    }

    return \@lines;
}

sub resolve_conflict
{
    my $conflict = shift;

    # TODO: consider pager?
    print "Conflict:\n";
    for my $line (@{Amling::Git::G3MD::Utils::format_conflict($conflict)})
    {
        print "   $line\n";
    }

    while(1)
    {
        print "> ";
        my $ans = <>;
        chomp $ans;

        if($ans eq '')
        {
            return resolve_conflict($conflict);
        }

        if($ans eq 'h' || $ans eq '?')
        {
            print map { "$_\n" } @{all_help()};
            next;
        }

        for my $resolver (@resolvers)
        {
            my $result = $resolver->handle($ans, $conflict);
            next unless($result);
            return resolve_blocks($result);
        }

        print "?\n";
    }
}

sub all_help
{
    my @help;
    for my $resolver (@resolvers)
    {
        push @help, $resolver->help();
    }
    @help = sort { $a->[0] cmp $b->[0] } @help;
    @help = map { $_->[1] } @help;
    return \@help;
}

use Amling::Git::G3MD::Resolver::Auto;
use Amling::Git::G3MD::Resolver::BackSplit;
use Amling::Git::G3MD::Resolver::Characters;
use Amling::Git::G3MD::Resolver::Edit;
use Amling::Git::G3MD::Resolver::Git;
use Amling::Git::G3MD::Resolver::LeftBack;
use Amling::Git::G3MD::Resolver::LeftFront;
use Amling::Git::G3MD::Resolver::Memory::Main;
use Amling::Git::G3MD::Resolver::Memory::Query;
use Amling::Git::G3MD::Resolver::Memory::Record;
use Amling::Git::G3MD::Resolver::Ours;
use Amling::Git::G3MD::Resolver::Punt;
use Amling::Git::G3MD::Resolver::RightBack;
use Amling::Git::G3MD::Resolver::RightFront;
use Amling::Git::G3MD::Resolver::Sort;
use Amling::Git::G3MD::Resolver::Split;
use Amling::Git::G3MD::Resolver::Theirs;
use Amling::Git::G3MD::Resolver::ThreeEdit;
use Amling::Git::G3MD::Resolver::TwoEdit;

1;
