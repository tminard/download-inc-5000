#!/usr/bin/env perl

use strict;
use Mojo::DOM;
use Mojo::Collection;

my $file = $ARGV[0];
my $starting_record = $ARGV[1];
my $year = $ARGV[2];

open FILE, $file or die $!;
my $html = do { local $/; <FILE>};

my $dom = Mojo::DOM->new($html);
print "Processing file for records starting at $starting_record...\n";

my $total = 0;
open (MYFILE, ">>list_$year.csv");
if ($starting_record == 0) {
	print MYFILE "Rank,Company Name,3-Year % Growth,Revenue,Industry,# of Employees,City,State\n";
}
for my $el ($dom->at('#inc5000_table')->find('td')->each) {
	++$total;
	my $company_name_nested = $el->at('a');

	my $text = "";
	if ($company_name_nested) {
		$text = $company_name_nested->text;
	} else {
		$text = $el->text;
	}
	$text =~ s/,//g;
	print MYFILE "$text";
	if ($total % 8 > 0) {
		print MYFILE ", ";
	}
	if ($total % 8 == 0) {
		print MYFILE "\n";
	}
}
close (MYFILE);