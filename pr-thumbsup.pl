#!bin/perl

use warnings;
use strict;
use Net::GitHub;
use Data::Dumper;

my @labels_to_remove = (qr/ready for review/i);
my @labels_to_add = ("Reviewed");

open FILE, ".token" or die "Couldn't open GiHub token file: $!"; 
my $gh_token = join("", <FILE>); 
close FILE;


my $gh = Net::GitHub->new(access_token => $gh_token, RaiseError => 1);

my $pr_user  = $ARGV[0] || usage();
my $pr_repo  = $ARGV[1] || usage();
my $pr_issue = $ARGV[2] || usage();
my $extra  = $ARGV[3]; #Optional

$gh->set_default_user_repo($pr_user, $pr_repo);
my $pr = $gh->pull_request->pull($pr_issue);
my $issue = $gh->issue;

print "Giving +1 to $pr_user/$pr_repo#$pr_issue: \"$pr->{title}\"\n";
print "Hit enter to continue.";
getc;


post_comment();
twiddle_labels();

print "done.";
exit 0;

sub post_comment {
	my $msg = ":+1: as of $pr->{head}->{sha}.";
	if (defined($extra)) {
		$msg .= "\n\n$extra";
	}

	my $comment = $issue->create_comment($pr_issue, {
			"body" => $msg
		});

}

sub twiddle_labels {
	my $labels = $issue->issue_labels($pr_issue);

	foreach my $l (@$labels) {
		foreach my $re (@labels_to_remove) {
			if ($l->{name} =~ $re) {
				print "Removing label $l->{name}\n";
				$issue->delete_issue_label($pr_issue, $l->{name});
				last;
			}
		}
	}

	print "Adding labels " . join(", ", @labels_to_add) . "\n";
	$issue->create_issue_label($pr_issue, \@labels_to_add);
}

sub usage {
	print "Usage: pr-thumbsup.pl <user> <repository> <issue #>";
	exit 1;
}
