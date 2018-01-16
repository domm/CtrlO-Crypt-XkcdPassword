#!/usr/bin/perl
use Test::More;
use Test::Exception;
use lib './lib';
use lib './t';

use CtrlO::Crypt::XkcdPassword;

subtest 'wordlist from file' => sub {
    my $pwgen = CtrlO::Crypt::XkcdPassword->new(
        wordlist => './t/fixtures/aa_wordlist.txt' );

    my $pw = $pwgen->xkcd;
    is( $pw, 'AaAaAaAa', 'a lot of aas' );

    my $pw2 = $pwgen->xkcd( words => 3, digits => 1 );
    like( $pw2, qr/^AaAaAa\d$/, 'less aas, but a digit' );
};

subtest 'wordlist from Wordlist' => sub {
    my $pwgen = CtrlO::Crypt::XkcdPassword->new(
        wordlist => 'fixtures::AaWordlist' );

    my $pw = $pwgen->xkcd;
    is( $pw, 'AaAaAaAa', 'a lot of aas' );

    my $pw2 = $pwgen->xkcd( words => 3, digits => 1 );
    like( $pw2, qr/^AaAaAa\d$/, 'less aas, but a digit' );
};

subtest 'wordlist from Crypt::Diceware' => sub {
    my $pwgen = CtrlO::Crypt::XkcdPassword->new(
        wordlist => 'fixtures::AaDiceware' );

    my $pw = $pwgen->xkcd;
    is( $pw, 'AaAaAaAa', 'a lot of aas' );

    my $pw2 = $pwgen->xkcd( words => 3, digits => 1 );
    like( $pw2, qr/^AaAaAa\d$/, 'less aas, but a digit' );
};

subtest 'failures' => sub {
    throws_ok {
        CtrlO::Crypt::XkcdPassword->new(
            wordlist => './no/such/file.txt' )
    }
    qr/either a Perl module or a file/, 'no such file';

    throws_ok {
        CtrlO::Crypt::XkcdPassword->new( wordlist => 'No::Such::Module' )
    }
    qr{Can't locate No/Such/Module.pm}, 'no such module';

    throws_ok {
        CtrlO::Crypt::XkcdPassword->new(
            wordlist => 'fixtures::NotAList' )
    }
    qr{Cannot find wordlist in fixtures::NotAList}, 'Not a wordlist-module';
};

done_testing();
