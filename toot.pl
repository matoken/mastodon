#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use utf8;
use Mastodon::Client;

my $client = Mastodon::Client->new(
  instance      => 'inari.opencocon.org',
  name          => 'PerlBot',
  client_id     => '',
  client_secret => '',
  access_token  => '',
);

my $message = Encode::decode_utf8( join(' ', @ARGV ) );

$client->post( statuses => {
  status => $message,
  visibility => 'public',
});
print encode('utf-8', "[$message]\n" );
