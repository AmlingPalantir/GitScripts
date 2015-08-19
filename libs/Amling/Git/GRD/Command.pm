package Amling::Git::GRD::Command;

use strict;
use warnings;

my @handlers;

sub add_command
{
    my $pfn = shift;

    push @handlers, $pfn;
}

sub parse
{
    my $s0 = shift;
    my $s1 = shift;

    for my $handler (@handlers)
    {
        my $ret = $handler->($s0, $s1);

        if(defined($ret))
        {
            return $ret;
        }
    }

    die "Unintelligible command at: $s0";
}

use Amling::Git::GRD::Command::Branch;
use Amling::Git::GRD::Command::CachedMerge;
use Amling::Git::GRD::Command::Edit;
use Amling::Git::GRD::Command::FSplatter;
use Amling::Git::GRD::Command::Fixup;
use Amling::Git::GRD::Command::Head;
use Amling::Git::GRD::Command::HooksAdd;
use Amling::Git::GRD::Command::HooksPop;
use Amling::Git::GRD::Command::HooksPush;
use Amling::Git::GRD::Command::Load;
use Amling::Git::GRD::Command::Merge;
use Amling::Git::GRD::Command::Perl;
use Amling::Git::GRD::Command::Pick;
use Amling::Git::GRD::Command::Pop;
use Amling::Git::GRD::Command::Push;
use Amling::Git::GRD::Command::Save;
use Amling::Git::GRD::Command::Shell;
use Amling::Git::GRD::Command::Splatter;
use Amling::Git::GRD::Command::Squash;
use Amling::Git::GRD::Command::Verify;

1;
