use strict;
use warnings;

use XML::Feed;
use URI;
use Cache::File;
use URI::Fetch;

binmode(STDOUT, ":utf8");

my $target = 'http://b.hatena.ne.jp/hotentry.rss';

my $cache = Cache::File->new( cache_root => '/tmp/cache' );
my $res = URI::Fetch->fetch(
    $target,
    Cache => $cache
) or die URI::Fetch->errstr;

my $feed = XML::Feed->parse(\($res->content));

for my $entry ($feed->entries) {
    print sprintf("%s\tcall unite#util#open('%s')\n", $entry->title, $entry->link);
}

