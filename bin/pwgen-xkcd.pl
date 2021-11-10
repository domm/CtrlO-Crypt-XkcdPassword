#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

# PODNAME: pwgen-xkcd.pl
# ABSTRACT: Generate a xkcd-style password
# VERSION

use CtrlO::Crypt::XkcdPassword;
use Getopt::Long;
use Pod::Usage qw(pod2usage);

binmode STDOUT, ":utf8";

my $words    = 4;
my $digits   = 0;
my $language = 'en-GB';
my $wordlist = '';
my $help     = 0;

GetOptions(
    "words=i"    => \$words,
    "digits=i"   => \$digits,
    "language=s" => \$language,
    "wordlist=s" => \$wordlist,
    "help|?"     => \$help
);
pod2usage(1) if ($help);
say CtrlO::Crypt::XkcdPassword->new( language => $language, wordlist => $wordlist )
    ->xkcd( words => $words, digits => $digits );

__END__

=head1 USAGE

  pwgen-xkcd.pl [options]

  Options:
    --words      Number of words to generate, default 4
    --digits     Add some digits, default 0
    --language   Language of word list, default en-GB

=head1 SEE ALSO

See C<perldoc CtrlO::Crypt::XkcdPassword> for even more info.
