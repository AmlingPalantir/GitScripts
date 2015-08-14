package Amling::Git::GRD::Command::Perl;

use strict;
use warnings;

use Amling::Git::GRD::Command;
use Amling::Git::Utils;

sub handler
{
    my $s0 = shift;
    my $s1 = shift;

    if($s0 ne 'perl')
    {
        return undef;
    }

    my @code;
    my $s1_new = [@$s1];
    while(@$s1_new)
    {
        my $line = shift @$s1_new;
        if($line eq '/perl')
        {
            my $sub = eval join("\n", 'sub {', 'my $g = shift;', @code, '}');
            if($@)
            {
                warn $@;
                # TODO: surface known errors, here and elsewhere
                return undef;
            }
            return [__PACKAGE__->new($sub), $s1_new];
        }
        push @code, $line;
    }

    return undef;
}

sub new
{
    my $class = shift;
    my $sub = shift;

    my $self =
    {
        'sub' => $sub,
    };

    bless $self, $class;

    return $self;
}

sub str
{
    return 'perl ...';
}

sub execute
{
    my $self = shift;
    my $ctx = shift;

    $ctx->materialize_head();
    $self->{'sub'}->(Amling::Git::GRD::Command::Perl::G->new($ctx));
}

Amling::Git::GRD::Command::add_command(\&handler);

package Amling::Git::GRD::Command::Perl::G;

sub new
{
    my $class = shift;
    my $ctx = shift;

    my $self =
    {
        'ctx' => $ctx,
    };

    bless $self, $class;

    return $self;
}

sub eval
{
    my $self = shift;
    my ($commands, $problems) = Amling::Git::GRD::Parser::parse([@_]);
    if(!defined($commands))
    {
        die join("\n", @$problems);
    }

    for my $command (@$commands)
    {
        print "Interpretting perl-given: " . $command->str() . "\n";
        $command->execute($self->{'ctx'});
    }
}

sub head
{
    my $self = shift;
    return $self->commit('HEAD');
}

sub commit
{
    my $self = shift;
    my $arg = shift;
    $arg = Amling::Git::Utils::convert_commitlike($arg);
    my $c = undef;
    Amling::Git::Utils::log_commits(['-1', $arg], sub { $c = shift; });
    return $c;
}

sub ctx
{
    my $self = shift;
    return $self->{'ctx'};
}

1;
