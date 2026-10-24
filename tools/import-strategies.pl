#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(basename);
use File::Path qw(make_path);
use Text::ParseWords qw(shellwords);

my ($source, $destination) = @ARGV;
die "Usage: $0 <Flowseal checkout> <destination>\n" unless $source && $destination;
make_path($destination);

my %aliases = (
    'general'                    => 'general',
    'general (ALT)'              => 'alt',
    'general (ALT2)'             => 'alt2',
    'general (ALT3)'             => 'alt3',
    'general (ALT4)'             => 'alt4',
    'general (ALT5)'             => 'alt5',
    'general (ALT6)'             => 'alt6',
    'general (ALT7)'             => 'alt7',
    'general (ALT8)'             => 'alt8',
    'general (ALT9)'             => 'alt9',
    'general (ALT10)'            => 'alt10',
    'general (ALT11)'            => 'alt11',
    'general (ALT12)'            => 'alt12',
    'general (ALT13)'            => 'alt13',
    'general (EXP)'              => 'exp',
    'general (FAKE TLS AUTO)'    => 'fake-tls-auto',
    'general (FAKE TLS AUTO ALT)'=> 'fake-tls-auto-alt',
    'general (FAKE TLS AUTO ALT2)'=> 'fake-tls-auto-alt2',
    'general (FAKE TLS AUTO ALT3)'=> 'fake-tls-auto-alt3',
    'general (SIMPLE FAKE)'      => 'simple-fake',
    'general (SIMPLE FAKE ALT)'  => 'simple-fake-alt',
    'general (SIMPLE FAKE ALT2)' => 'simple-fake-alt2',
);

for my $path (glob("$source/general*.bat")) {
    my $stem = basename($path, '.bat');
    my $name = $aliases{$stem} // die "Unknown strategy name: $stem\n";
    open my $in, '<:raw', $path or die "Cannot read $path: $!\n";
    local $/;
    my $text = <$in>;
    close $in;

    $text =~ s/\r//g;
    my @lines = split /\n/, $text;
    my $command = '';
    my $capture = 0;
    for my $line (@lines) {
        if ($line =~ /^start\s+"zapret:.*?winws\.exe"\s+(.*)$/i) {
            $capture = 1;
            $line = $1;
        } elsif (!$capture) {
            next;
        }
        $line =~ s/\s*\^\s*$//;
        $command .= " $line";
        last if $line !~ /\^\s*$/ && $line !~ /^--/;
    }

    $command =~ s/%BIN%\\?/\@BIN\@\//g;
    $command =~ s/%LISTS%\\?/\@LISTS\@\//g;
    $command =~ s/%GameFilterTCP%/\@GAME_TCP\@/g;
    $command =~ s/%GameFilterUDP%/\@GAME_UDP\@/g;
    $command =~ s/\^!/!/g;
    $command =~ s/\\/\//g;
    my @args = shellwords($command);
    @args = grep { $_ !~ /^--wf-(?:tcp|udp)=/ } @args;

    my $out_path = "$destination/$name.conf";
    open my $out, '>:raw', $out_path or die "Cannot write $out_path: $!\n";
    print {$out} "# Generated from $stem.bat (Flowseal 1.10.4)\n";
    print {$out} "$_\n" for @args;
    close $out;
}
