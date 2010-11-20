use strict;
use warnings;

use XML::Feed;
use URI;
use Perl6::Say;
use URI::Fetch;

my $target = 'http://b.hatena.ne.jp/hotentry.rss';

my $res = URI::Fetch->fetch( $target );
my $feed = XML::Feed->parse(\($res->content));

for my $entry ($feed->entries) {
    say sprintf("%s,call system('open %s')", $entry->title, $entry->link);
}
