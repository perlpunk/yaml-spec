#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;
use IO::All;

my $file1 = "online-spec.html";
my $file2 = "spec.html";
my $html1 = io($file1)->all;
my $html2 = io($file2)->all;
my @ids1 = $html1 =~ m/href="\#id(\d+)">([\d\.]+ .+?)<\/a>/g;
#my @it1 = $html1 =~ m{id="id(\d+)" class="indexterm"><\/a><a class="link" href="\#([^"]+)"}g;
my @it1 = $html1 =~ m{id="id(\d+)" class="indexterm"><\/a><a id="([^"]+)"}g;

my @_ithref1 = $html1 =~ m{id="id(\d+)" class="indexterm"><\/a><a class="link" href="\#([^"]+)"}g;
my @_ithref2 = $html2 =~ m{id="idp(\d+)" class="indexterm"><\/a><a class="link" href="\#([^"]+)"}g;
my %ithref1;
my %ithref2;
my $loop = 0;
for (my $i = 0; $i < @_ithref1; $i+= 2) {
    my $id = $_ithref1[ $i ];
    my $text = $_ithref1[ $i + 1 ];
#    my $text = $_ithref1{ $id };
    push @{ $ithref1{ $text } }, $id;
#    last if $loop++ > 3;
}
my %map;
$loop = 0;
for (my $i = 0; $i < @_ithref1; $i+= 2) {
    my $id = $_ithref2[ $i ];
    my $text = $_ithref2[ $i + 1 ];
#    my $text = $_ithref2{ $id };
    my $num = $ithref2{ $text }->{count}++ || 0;
    my $id1 = $ithref1{ $text }->[ $num ];
    $map{ $id } = $id1;
#    last if $loop++ > 3;
}
#warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%_ithref1], ['_ithref1']);
#warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%_ithref2], ['_ithref2']);
#warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ithref1], ['ithref1']);
#warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ithref2], ['ithref2']);
#warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%map], ['map']);

my @ids2 = $html2 =~ m/href="\#idp(\d+)">([\d\.]+ .+?)<\/a>/g;
my @it2 = $html2 =~ m{id="idp(\d+)" class="indexterm"><\/a><a id="([^"]+)"}g;
#my @it2 = $html2 =~ m{id="idp(\d+)" class="indexterm"><\/a><a class="link" href="\#([^"]+)"}g;
for (@ids1, @ids2) {
    s/<.*?>//g;
    s/[^\w\. ]+//g;
}

my %ids1 = ((reverse @it1), (reverse @ids1));
my %ids2 = ((reverse @it2), (reverse @ids2));
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ids1], ['ids1']);
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ids2], ['ids2']);
for my $text (sort keys %ids1) {
    my $id1 = $ids1{ $text };
    my $id2 = $ids2{ $text } // "?";
    $map{ $id2 } = $id1;
}
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%map], ['map']);
no warnings 'uninitialized';
$html2 =~ s/"(\#?)idp(\d+)"/qq{"${1}id} . ($map{ $2 } || $2) . q{"}/eg;
say $html2;
