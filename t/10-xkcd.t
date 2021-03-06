#!/usr/bin/perl
use Test::More;
use Test::Exception;
use lib 'lib';

use CtrlO::Crypt::XkcdPassword;

my $pwgen = CtrlO::Crypt::XkcdPassword->new;

subtest 'all defaults' => sub {
    my $pw = $pwgen->xkcd;

    like(
        $pw,
        qr/^(\p{Uppercase}\p{Lowercase}+){4}$/,
        'looks like a XKCD pwd'
    );
};

subtest 'words=>3' => sub {
    my $pw = $pwgen->xkcd( words => 3 );

    like(
        $pw,
        qr/^(\p{Uppercase}\p{Lowercase}+){3}$/,
        'looks like a XKCD pwd with 3 words'
    );
};

subtest 'words=>3, digits=>10' => sub {
    my $pw = $pwgen->xkcd( words => 3, digits => 10 );

    like(
        $pw,
        qr/^(\p{Uppercase}\p{Lowercase}+){3}\d{10}$/,
        'looks like a XKCD pwd with 3 words and 10 digits'
    );
};

subtest 'words=>3, digits=>3' => sub {
    my $pw = $pwgen->xkcd( words => 3, digits => 3 );

    like(
        $pw,
        qr/^(\p{Uppercase}\p{Lowercase}+){3}\d{3}$/,
        'looks like a XKCD pwd with 3 words and 3 digits'
    );
};

subtest 'words=>4, digits=>0' => sub {
    my $pw = $pwgen->xkcd( words => 4, digits => 0 );

    like(
        $pw,
        qr/^(\p{Uppercase}\p{Lowercase}+){4}$/,
        'looks like a XKCD pwd with 4 words and 0 digits'
    );
};

subtest 'invalid params: key' => sub {
    foreach my $param (qw(wordx digitx)) {
        throws_ok { $pwgen->xkcd( $param => 3 ) }
            qr/^Invalid key/,
            'Invalid key received: '.$param;
    }
};

subtest 'invalid params: value' => sub {
    foreach my $param (
        [ words => 0.5],
        [ words => -1],
        [ words => 'a'],
        [ words => '123a' ],
        [ words => 'a123' ],
        [ words => "" ],
        [ digits => 0.5 ],
        [ digits => -1 ],
        [ digits => 'a' ],
        [ digits => '123a' ],
        [ digits => 'a123' ],
        [ digits => "" ],
    ) {
        throws_ok { $pwgen->xkcd( @$param ) }
            qr/^Invalid value/,
            sprintf('Invalid value received for %s: %s', @$param);
    }
};

done_testing();
