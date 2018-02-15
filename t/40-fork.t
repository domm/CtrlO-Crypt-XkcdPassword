#!/usr/bin/perl
use Test::More;
use strict;
use warnings;
use 5.010;
use lib 'lib';

use CtrlO::Crypt::XkcdPassword;

my $pwgen = CtrlO::Crypt::XkcdPassword->new;
say "...";

for my $i (1..2) {
    my $pid = fork();
    if (not $pid) {
        my $pw = $pwgen->xkcd(words=>1,digits=>$i);
        say "fork $i: $pw";

        sleep $i;

        my $pw2 = $pwgen->xkcd(words=>1,digits=>$i);
        say "fork $i: $pw2";

        exit;
    }
}


my $pw = $pwgen->xkcd(words=>1);
say "parent: $pw";

sleep 3;

for (1..2) {
    my $finished = wait();
}

my $pw2 = $pwgen->xkcd(words=>1);
say "parent: $pw2";

done_testing();
