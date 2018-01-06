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

use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(entropy wordlist _list));

sub new {
    my ( $class, $args ) = @_;

    my %object;

    # init the wordlist
    $object{wordlist} =
        $args->{wordlist} || 'CtrlO::Crypt::XkcdPassword::Wordlist';
    if ( $object{wordlist} =~ /::/ ) {

        # TODO
        $object{_list} = [qw(correct horse battery staple)];
    }
    elsif ( -r $object{wordlist} ) {
        my @list = do { local (@ARGV) = $object{wordlist}; <> };
        chomp(@list);
        $object{_list} = \@list;
    }
    else {
        croak(    'Invalid wordlist: >'
                . $object{wordlist}
                . '<. Has to be either a Perl module or a file' );
    }

    # poor person's lazy_build
    $object{entropy} = $args->{entropy} || $class->_build_entropy;

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

sub xkcd {
    my ( $self, $args ) = @_;
    my $word_count = $args->{words} || 4;

    my $words = with_entropy_source(
        $self->entropy,
        sub {
            shuffle_r( choose_r( $word_count, $self->_list ) );
        }
    );

    if ( my $d = $args->{digits} ) {
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

1;

__END__

=head1 SYNOPSIS

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


