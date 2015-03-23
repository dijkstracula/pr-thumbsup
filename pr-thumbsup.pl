#!bin/perl

use warnings;
use strict;
use Net::GitHub;
use Data::Dumper;

my @labels_to_remove = ["Ready for review"];
my @labels_to_add = ["Reviewed"];

open FILE, ".token" or die "Couldn't open GiHub token file: $!"; 
my $gh_token = join("", <FILE>); 
close FILE;


my $gh = Net::GitHub->new(access_token => $gh_token, RaiseError => 1);

my $pr_user  = $ARGV[0] || usage();
my $pr_repo  = $ARGV[1] || usage();
my $pr_issue = $ARGV[2] || usage();
my $comment  = $ARGV[3]; #Optional

$gh->set_default_user_repo($pr_user, $pr_repo);
my $issue = $gh->issue->issue($pr_issue);

print Dumper $issue;

sub usage {
	print "Usage: pr-thumbsup.pl <user> <repository> <issue #>";
	exit 1;
}
