package CtrlO::Crypt::XkcdPassword;
use strict;
use warnings;

# ABSTRACT: Yet another XKCD style password generator

our $VERSION = '0.900';

use Carp qw(croak);
use Crypt::Rijndael;
use Crypt::URandom;
use Data::Entropy qw(with_entropy_source);
use Data::Entropy::Algorithms qw(rand_int pick_r shuffle_r choose_r);
use Data::Entropy::RawSource::CryptCounter;
use Data::Entropy::Source;
use Module::Runtime qw(use_module);

use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(entropy wordlist _list language));

=method new

  my $pw_generator = CtrlO::Crypt::XkcdPassword->new;

Initialize a new object. Uses C<CtrlO::Crypt::XkcdPassword::Wordlist::en_gb>
as a word list per default. The default entropy is based on
C<Crypt::URandom>, i.e. '/dev/urandom' and should be random enough (at
least more random than plain old C<rand()>).

If you want / need to supply another source of entropy, you can do so
by setting up an instance of C<Data::Entropy::Source> and passing it
to C<new> as C<entropy>.

  my $pw_generator = CtrlO::Crypt::XkcdPassword->new(
      entropy => Data::Entropy::Source->new( ... )
  );

To use one of the included language-specific wordlists, do:

  my $pw_generator = CtrlO::Crypt::XkcdPassword->new(
      language => 'en-GB',
  );

Available languages are:

=over

=item * en-GB

=back

You can also provide your own custom wordlist, either in a file:

  my $pw_generator = CtrlO::Crypt::XkcdPassword->new(
      wordlist => '/path/to/file'
  );

Or in a module:

  my $pw_generator = CtrlO::Crypt::XkcdPassword->new(
      wordlist => 'My::Wordlist'
  );

See L<Defining custom word lists> for more info

=cut

sub new {
    my ( $class, %args ) = @_;

    my %object;

    # init the wordlist
    my @list;
    if ($args{wordlist}) {
        $object{wordlist} = $args{wordlist};
    }
    else {
        my $lang = lc($args{language} || 'en-GB');
        $lang=~s/-/_/g;
        $object{wordlist} = 'CtrlO::Crypt::XkcdPassword::Wordlist::'.$lang;
    }

    if ( -r $object{wordlist} ) {
        open (my $fh, '<:encoding(UTF-8)', $object{wordlist});
        while (my $word = <$fh>) {
            chomp($word);
            $word=~s/\s//g;
            push(@list, $word);
        }
        $object{_list} = \@list;
    }
    elsif ( $object{wordlist} =~ /::/ ) {
        eval {
            use_module($object{wordlist});
        };
        if ($@) {
            croak("Cannot load wordlist module ".$object{wordlist});
        }
        my $pkg = $object{wordlist};
        no strict 'refs';

        # do we have a __DATA__ section, indication a subclass of https://metacpan.org/release/WordList
        my $data = do { \*{"$pkg\::DATA"} };
        if (defined fileno *$data) {
            while (my $word = <$data>) {
                chomp($word);
                $word=~s/\s//g;
                push(@list, $word);
            }
            $object{_list} = \@list;
        }
        # do we have @Words, indication Crypt::Diceware
        elsif ( @{"${pkg}::Words"}) {
            $object{_list} = \@{"${pkg}::Words"};
        }
        else {
            croak("Cannot find wordlist in $pkg");
        }
    }
    else {
        croak(    'Invalid wordlist: >'
                . $object{wordlist}
                . '<. Has to be either a Perl module or a file' );
    }

    # poor person's lazy_build
    $object{entropy} = $args{entropy} || $class->_build_entropy;

    return bless \%object, $class;
}

sub _build_entropy {
    my $class = shift;
    return Data::Entropy::Source->new(
        Data::Entropy::RawSource::CryptCounter->new(
            Crypt::Rijndael->new( Crypt::URandom::urandom(32) )
        ),
        "getc"
    );
}

=method xkcd

  my $pw = $pw_generator->xkcd;
  my $pw = $pw_generator->xkcd( words  => 3 );
  my $pw = $pw_generator->xkcd( digits => 2 );

Generate a random, XKCD-style password (actually a passphrase, but
we're all trying to getting things done, so who cares..)

Per default will return 4 randomly chosen words from the word list,
each word's first letter turned to upper case, and concatenated
together into one string:

  $pw_generator->xkcd;
  # CorrectHorseBatteryStaple

You can get a different number of words by passing in C<words>. But
remember that anything smaller than 3 will probably make for rather
poor passwords, and anything bigger than 7 will be hard to remember.

You can also pass in C<digits> to append a random number consisting of
C<digits> digits to the password:

  $pw_generator->xkcd( words => 3, digits => 2 );
  # StapleBatteryCorrect75

=cut

sub xkcd {
    my ( $self, %args ) = @_;
    my $word_count = $args{words} || 4;

    my $words = with_entropy_source(
        $self->entropy,
        sub {
            shuffle_r( choose_r( $word_count, $self->_list ) );
        }
    );

    if ( my $d = $args{digits} ) {
        push(
            @$words,
            sprintf(
                '%0' . $d . 'd',
                with_entropy_source(
                    $self->entropy, sub { rand_int( 10 ** $d ) }
                )
            )
        );
    }
    return join( '', map {ucfirst} @$words );
}

'correct horse battery staple';

__END__

=head1 SYNOPSIS

  use CtrlO::Crypt::XkcdPassword;
  my $password_generator = CtrlO::Crypt::XkcdPassword->new;

  say $password_generator->xkcd;
  # LimousineAllegeClergymanEconomic

  say $password_generator->xkcd( words => 3 );
  # ObservantFiresideMacho

  say $password_generator->xkcd( words => 3, digits => 3 );
  # PowerfulSpreadScarf645

  # Use custom word list
  CtrlO::Crypt::XkcdPassword->new(
    wordlist => '/path/to/wordlist'
  );
  CtrlO::Crypt::XkcdPassword->new(
    wordlist => 'Some::Wordlist::From::CPAN'
  );

  # Use another source of randomness (aka entropy)
  CtrlO::Crypt::XkcdPassword->new(
    entropy => Data::Entropy::Source->new( ... );
  );

=head1 DESCRIPTION

C<CtrlO::Crypt::XkcdPassword> generates a random password using the
algorithm suggested in L<https://xkcd.com/936/>: It selects 4 words
from a curated list of words and combines them into a hopefully easy
to remember password.

But L<https://xkcd.com/927/> also applies to this module, as there are
already a lot of modules on CPAN also implementing
L<https://xkcd.com/936/>. We still wrote a new one, mainly because we
wanted to use a strong source of entropy.

=head1 Defining custom word lists

Please note that C<language> is only supported for the wordlists
included with this distribution.

=head2 in a plain file

Put your word list into a plain file, one line per word. Install this
file somewhere on your system. You can now use this word list like
this:

  CtrlO::Crypt::XkcdPassword->new(
    wordlist => '/path/to/wordlist'
  );

=head2 in a Perl module using the Wordlist API

Perlancar came up with a unified API for various word list modules,
implemented in L<Wordlist|https://metacpan.org/pod/WordList>. Pack
your list into a module adhering to this API, install the module, and
load your word list:

  CtrlO::Crypt::XkcdPassword->new(
    wordlist => 'Your::Cool::Wordlist'
  );

You can check out L<CtrlO::Crypt::XkcdPassword::Wordlist> (included in
this distribution) for an example. But it's really quite simple: Just
subclass C<Wordlist> and put your list of words into the C<__DATA__>
section of the module, one line per word.

=head2 in a Perl module using the Crypt::Diceware API

David Golden uses a different API in his L<Crypt::Diceware> module,
which inspired the design of L<CtrlO::Crypt::XkcdPassword>. To use one
of those word lists, use:

  CtrlO::Crypt::XkcdPassword->new(
    wordlist => 'Crypt::Diceware::Wordlist::Common'
  );

(yes, this looks just like when using C<Wordlist>. We inspect the
wordlist module and try to figure out what kind of API you're using)

To create a module using the L<Crypt::Diceware> wordlist API, just
create a package containing a public array C<@Words> containing your
word list.

=head1 pwgen-xkcd.pl

This distributions includes a simple wrapper script, L<pwgen-xkcd.pl>.

=head1 RUNNING FROM GIT

This is B<not> the recommended way to install / use this module. But
it's handy if you want to submit a patch or play around with the code
prior to a proper installation.

=head2 Carton

  git clone git@github.com:domm/CtrlO-Crypt-XkcdPassword.git
  carton install
  carton exec perl -Ilib -MCtrlO::Crypt::XkcdPassword -E 'say CtrlO::Crypt::XkcdPassword->new->xkcd'

=head2 cpanm & local::lib

  git clone git@github.com:domm/CtrlO-Crypt-XkcdPassword.git
  cpanm -L local --installdeps .
  perl -Mlocal::lib=local -Ilib -MCtrlO::Crypt::XkcdPassword -E 'say CtrlO::Crypt::XkcdPassword->new->xkcd'

=head1 SEE ALSO

Inspired by L<https://xkcd.com/936/> and L<https://xkcd.com/927/>

There are a lot of similar modules on CPAN, so I just point you to
L<Neil Bower's comparison of CPAN modules for generating passwords|http://neilb.org/reviews/passwords.html>

I leanrned the usage of C<Data::Entropy> is from
L<https://metacpan.org/pod/Crypt::Diceware>, which also implements an
algorithm to generate a random passphrase.

=head1 THANKS

Thanks to L<Ctrl O|http://www.ctrlo.com/> for funding the development of this module.

