#!/usr/bin/perl
use Test::More;
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

subtest 'wordx=>3' => sub {

    eval {
        my $pw = $pwgen->xkcd( wordx => 3 );
    };

    like(
        $@,
        qr/^Invalid key/,
        'Invalid key received'
    );
};

subtest 'words=>0' => sub {

    eval {
        my $pw = $pwgen->xkcd( words => 0 );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for words'
    );
};

subtest 'words=>-1' => sub {

    eval {
        my $pw = $pwgen->xkcd( words => -1 );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for words'
    );
};

subtest 'words=>a' => sub {

    eval {
        my $pw = $pwgen->xkcd( words => 'a' );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for words'
    );
};

subtest 'digitx=>2' => sub {

    eval {
        my $pw = $pwgen->xkcd( digitx => 2 );
    };

    like(
        $@,
        qr/^Invalid key/,
        'Invalid key received'
    );
};

subtest 'digits=>0' => sub {

    eval {
        my $pw = $pwgen->xkcd( digits => 0 );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for digits'
    );
};

subtest 'digits=>-1' => sub {

    eval {
        my $pw = $pwgen->xkcd( digits => -1 );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for digits'
    );
};

subtest 'digits=>a' => sub {

    eval {
        my $pw = $pwgen->xkcd( digits => 'a' );
    };

    like(
        $@,
        qr/^Invalid value/,
        'Invalid value received for digits'
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

done_testing();
