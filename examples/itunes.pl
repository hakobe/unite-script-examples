use strict;
use warnings;
use Mac::AppleScript qw(RunAppleScript);
use Perl6::Say;
use FindBin;

BEGIN {
    $ENV{ITUNES_TELL} = 1;
};

my $me = "$0";
my $mode = shift || '';

if ($mode eq 'play_n') {
    &play_n(@ARGV);
}
elsif ($mode eq 'play') {
}
elsif ($mode eq 'stop') {
}
elsif ($mode eq 'next') {
}
elsif ($mode eq 'prev') {
}
else {
    &panel(@ARGV);
    &list(@ARGV);
} 

sub play {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            play
        end tell
SCRIPT
    RunAppleScript($script);
}

sub stop {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            stop
        end tell
SCRIPT
    RunAppleScript($script);
}

sub next {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            next track
        end tell
SCRIPT
    RunAppleScript($script);
}

sub prev {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            previous track
        end tell
SCRIPT
    RunAppleScript($script);
}

sub play_n {
    my $n = shift;
    my $script = <<"SCRIPT";
        tell application "iTunes"
            set cPlaylist to current playlist
            play track $n of cPlaylist
        end tell
SCRIPT
    RunAppleScript($script);
}

sub panel {
    print <<"PANEL"
|>,call system('perl $me play')
[],call system('perl $me stop')
>>,call system('perl $me next')
<<,call system('perl $me prev')
PANEL
}

sub list {
    my $script = <<"SCRIPT";
        tell application "iTunes"
            set cPlaylist to current playlist
            set resultString to ""
            repeat with i from 1 to count of tracks in cPlaylist
                set sName to name of track i in cPlaylist
                set sArtist to artist of track i in cPlaylist
                set sTime to time of track i in cPlaylist
                set resultString to resultString & sName & "\t" & sArtist & "\t" & sTime & "\n"
            end repeat
            return resultString
        end tell
SCRIPT

    my $result = RunAppleScript($script);
    $result =~ s/^"//g;
    $result =~ s/"$//g;

    my $i = 1;
    my $songs = [ map { 
        my $vals = [split /\t/, $_];
        +{
            position => $i++,
            title    => $vals->[0],
            artist   => $vals->[1],
            time     => $vals->[2],
        };
    } split /\n/, $result ];

    for my $song (@$songs) {
        say sprintf(qq<%s(%s) - %s,call system('perl %s play_n %s')>, 
            $song->{title}, $song->{time}, $song->{artist},
            $me, $song->{position} 
        );
    }
}

