#!/usr/bin/perl
use Test::More;
use strict;
use warnings;
use 5.010;
use lib 'lib';
use Test::SharedFork;
use CtrlO::Crypt::XkcdPassword;

my $pwgen      = CtrlO::Crypt::XkcdPassword->new;
my $parent_pid = $$;

is( $pwgen->_pid, $parent_pid, 'in parent' );

for my $i ( 1 .. 2 ) {
    my $pid = fork();
    if ( not $pid ) {
        is( $pwgen->_pid, $parent_pid,
            'xkcd not called, so still parent pid' );
        isnt( $pwgen->_pid, $$, 'pwgen->_pid not pid of fork' );

        my $pw = $pwgen->xkcd( words => 1, digits => $i );
        like( $pw, qr/^\p{Uppercase}\p{Lowercase}+\d+$/, "fork $i: $pw" );

        is( $pwgen->_pid, $$, 'xkcd called, so _pid is pid of fork' );

        sleep $i;

        my $pw2 = $pwgen->xkcd( words => 1, digits => $i );
        like( $pw2, qr/^\p{Uppercase}\p{Lowercase}+\d+$/, "fork $i: $pw2" );

        exit;
    }
}

is( $pwgen->_pid, $parent_pid, 'in parent, pid is unchanged' );
my $pw = $pwgen->xkcd( words => 1 );
like( $pw, qr/^\p{Uppercase}\p{Lowercase}+$/, "parent: $pw" );

sleep 2;

for ( 1 .. 2 ) {
    my $finished = wait();
}

is( $pwgen->_pid, $parent_pid, 'in parent, pid is still unchanged' );
my $pw2 = $pwgen->xkcd( words => 1 );
like( $pw2, qr/^\p{Uppercase}\p{Lowercase}+$/, "parent: $pw2" );

done_testing();
