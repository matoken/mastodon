#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use utf8;
#use Gtk2::Notify -init, 'Basic';
use Growl::GNTP;
use IPC::Open2;

# Mastodon streaming popup.
#
# "documentation/API.md at master · tootsuite/documentation
# https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md

$|=1;

# "documentation/Testing-with-cURL.md at master · tootsuite/documentation
# https://github.com/tootsuite/documentation/blob/master/Using-the-API/Testing-with-cURL.md
my $server = 'https://mstdn.maud.io/';
my $token = '';

my $growl = Growl::GNTP->new(AppName => "Mastodon");
$growl->register([
        { Name => "stream", },
        { Name => "mention", },
]);

# "documentation/Streaming-API.md at master · tootsuite/documentation
#  https://github.com/tootsuite/documentation/blob/master/Using-the-API/Streaming-API.md
#
# GET /api/v1/streaming/user
# Returns events that are relevant to the authorized user, i.e. home timeline and notifications
# GET /api/v1/streaming/public
# Returns all public statuses
# GET /api/v1/streaming/hashtag
# Returns all public statuses for a particular hashtag (query param tag)
#my $command = 'curl --header "Authorization: Bearer ' . $token . '" -s ' . $server . 'api/v1/streaming/public';
my $command = 'curl --header "Authorization: Bearer ' . $token . '" -s ' . $server . 'api/v1/streaming/user';
open(my $CMD, "$command |");
while(my $line=<$CMD>){
  if( $line !~ /^data/ ){next}
  $line =~s/^data: //o;
  my $pid = open2(*READ, *WRITE, 'jq -r .account.display_name,.account.acct,.content,.account.avatar_static');
  print WRITE $line;
  close(WRITE);
  my @list=<READ>;
  close(READ);
  $list[0] =~s/\n//og;
  $list[1] =~s/\n//og;
  $list[3] =~s/\n//og;
  my $message = `echo "$list[2]" | lynx -stdin -dump`;
  $growl->notify(
    Event => "stream",
    Title => "$list[0]($list[1])",
    Message => $message,
    Icon => $list[3],
  );
  print "[$message]\n";
}
