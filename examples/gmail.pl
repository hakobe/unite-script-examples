use strict;
use warnings;

use XML::Feed;
use LWP::UserAgent;
use HTTP::Request::Common;
use Config::Pit;

binmode(STDOUT, ":utf8");

my $config = pit_get("mail.google.com", require => {
    "username" => "your username",
    "password" => "your password"
});

my $ua = LWP::UserAgent->new;

my $req = GET('https://mail.google.com/mail/feed/atom');
$req->authorization_basic($config->{username}, $config->{password});

my $res = $ua->request($req);

my $feed = XML::Feed->parse(\($res->content));

for my $entry ($feed->entries) {
    my $summary = $entry->summary->body;
    $summary =~ s/^.*。\s+//g;
    print sprintf(qq<%s\tcall unite#util#open('%s')\n>, $summary, $entry->link);
}

