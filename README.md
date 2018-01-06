# NAME

CtrlO::Crypt::XkcdPassword - Yet another XKCD style password generator

# VERSION

version 0.900

# SYNOPSIS

    use CtrlO::Crypt::XkcdPassword;
    my $password_generator = CtrlO::Crypt::XkcdPassword->new;

    say $password_generator->xkcd;
    # LameSeaweedsLavaHeal

    say $password_generator->xkcd({ words => 3 });
    # TightLarkSpell

    say $password_generator->xkcd({ words => 3, digits => 3 });
    # WasteRoommateLugged220

    # Use custom word list
    CtrlO::Crypt::XkcdPassword->new({
      wordlist => '/path/to/wordlist'
    });
    CtrlO::Crypt::XkcdPassword->new({
      wordlist => 'Some::Wordlist::From::CPAN' # but there is no unified API for wordlist modules...
    });

    # Use another source of randomness (aka entropy)
    CtrlO::Crypt::XkcdPassword->new({
      entropy => Data::Entropy::Source->new( ... );
    });

# DESCRIPTION

`CtrlO::Crypt::XkcdPassword` generates a random password using the
algorithm suggested in [https://xkcd.com/936/](https://xkcd.com/936/): It selects 4 words
from a curated list of words and combines them into a hopefully easy
to remember password.

But [https://xkcd.com/927/](https://xkcd.com/927/) also applies to this module, as there are
already a lot of modules on CPAN also implementing
[https://xkcd.com/936/](https://xkcd.com/936/). We still wrote a new one, mainly because we
wanted to use a strong source of entropy.

# METHODS

## new

    my $pw_generator = CtrlO::Crypt::XkcdPassword->new;

    my $pw_generator = CtrlO::Crypt::XkcdPassword->new({
        wordlist => '/path/to/file'
    });

    my $pw_generator = CtrlO::Crypt::XkcdPassword->new({
        wordlist => 'CtrlO::Crypt::XkcdPassword::Wordlist'
    });

    my $pw_generator = CtrlO::Crypt::XkcdPassword->new({
        entropy => Data::Entropy::Source->new( ... )
    });

Initialize a new object. Uses `CtrlO::Crypt::XkcdPassword::Wordlist`
as a word list per default. The default entropy is based on
`Crypt::URandom`, i.e. '/dev/urandom' and should be random enough (at
least more random than plain old `rand()`).

If you want / need to supply another source of entropy, you can do so
by setting up an instance of `Data::Entropy::Source` and passing it
to `new` as `entropy`.

## xkcd

    my $pw = $pw_generator->xkcd;
    my $pw = $pw_generator->xkcd({ words  => 3 });
    my $pw = $pw_generator->xkcd({ digits => 2 });

Generate a random, XKCD-style password (actually a passphrase, but
we're all trying to getting things done, so who cares..)

Per default will return 4 randomly chosen words from the word list,
each word's first letter turned to upper case, and concatenated
together into one string:

    $pw_generator->xkcd;
    # CorrectHorseBatteryStaple

You can get a different number of words by passing in `words`. But
remember that anything smaller than 3 will probably make for rather
poor passwords, and anything bigger than 7 will be hard to remember.

You can also pass in `digits` to append a random number consisting of
`digits` digits to the password:

    $pw_generator->xkcd({ words => 3, digits => 2 });
    # StapleBatteryCorrect75

# RUNNING FROM GIT

This is **not** the recommended way to install / use this module. But
it's handy if you want to submit a patch or play around with the code
prior to a proper installation.

## Carton

    git clone git@github.com:domm/CtrlO-Crypt-XkcdPassword.git
    carton install
    carton exec perl -Ilib -MCtrlO::Crypt::XkcdPassword -E 'say CtrlO::Crypt::XkcdPassword->new->xkcd'

## cpanm & local::lib

    git clone git@github.com:domm/CtrlO-Crypt-XkcdPassword.git
    cpanm -L local --installdeps .
    perl -Mlocal::lib=local -Ilib -MCtrlO::Crypt::XkcdPassword -E 'say CtrlO::Crypt::XkcdPassword->new->xkcd'

# SEE ALSO

Inspired by [https://xkcd.com/936/](https://xkcd.com/936/) and [https://xkcd.com/927/](https://xkcd.com/927/)

There are a lot of similar modules on CPAN, so I just point you to
[Neil Bower's comparison of CPAN modules for generating passwords](http://neilb.org/reviews/passwords.html)

I leanrned the usage of `Data::Entropy` is from
[https://metacpan.org/pod/Crypt::Diceware](https://metacpan.org/pod/Crypt::Diceware), which also implements an
algorithm to generate a random passphrase.

# THANKS

Thanks to [CTRL-O](http://www.ctrlo.com/) for funding the development of this module.

# AUTHOR

Thomas Klausner <domm@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Thomas Klausner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
