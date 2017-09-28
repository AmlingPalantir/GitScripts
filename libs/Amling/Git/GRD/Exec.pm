package Amling::Git::GRD::Exec;

use strict;
use warnings;

use Amling::Git::GRD::Exec::Context;
use Amling::Git::Utils;

sub execute
{
    my $commands = shift;
    my $reason = shift;

    print "Detaching HEAD...\n";
    Amling::Git::Utils::run_system("git", "checkout", "HEAD~0") || die "Cannot checkout HEAD~0";

    my $ctx = Amling::Git::GRD::Exec::Context->new();

    my $ct = scalar(@$commands);
    my $n = 1;
    for my $command (@$commands)
    {
        print "Interpretting ($n/$ct): " . $command->str() . "\n";
        ++$n;

        $command->execute($ctx);
    }

    {
        my $branches = $ctx->get('branches', {});
        for my $branch (sort(keys(%$branches)))
        {
            print "Updating: $branch => " . $branches->{$branch} . "\n";
            Amling::Git::Utils::run_system("git", "update-ref", "-m", $reason, "refs/heads/$branch", $branches->{$branch}) || die "Cannot update $branch";
        }
    }

    {
        my $head = $ctx->get('head');
        if(defined($head))
        {
            my ($type, $v1) = @$head;

            if($type == 0)
            {
                print "Leaving detached head at $v1.\n";
                Amling::Git::Utils::run_system("git", "checkout", $v1) || die "Cannot checkout $v1";
            }
            elsif($type == 1)
            {
                print "Leaving head at branch $v1.\n";
                Amling::Git::Utils::run_system("git", "checkout", $v1) || die "Cannot checkout $v1";
            }
            else
            {
                die "Unknown head type: $type";
            }
        }
        else
        {
            print "No head set?  Leaving wherever.\n";
        }
    }

    print "Done.\n";
    my $grd_level = $ENV{'GRD_LEVEL'};
    if($grd_level)
    {
        print "Still inside GRD!\n";
        print "GRD level: " . $grd_level . "\n";
    }
}

1;
