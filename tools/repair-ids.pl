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
my @ids2 = $html2 =~ m/href="\#idp(\d+)">([\d\.]+ .+?)<\/a>/g;
for (@ids1, @ids2) {
    s/<.*?>//g;
    s/[^\w\. ]+//g;
}
my %ids1 = reverse @ids1;
my %ids2 = reverse @ids2;
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ids1], ['ids1']);
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%ids2], ['ids2']);
my %map;
for my $text (sort keys %ids1) {
    my $id1 = $ids1{ $text };
    my $id2 = $ids2{ $text };
    $map{ $id2 } = $id1;
}
warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\%map], ['map']);
$html2 =~ s/"(\#?)idp(\d+)"/"${1}id$map{ $2 }"/g;
say $html2;
