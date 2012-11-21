#!/usr/bin/env perl

use strict;
use Mojo::DOM;
use Mojo::Collection;
use File::Fetch;
use File::Copy qw(move);

my $num_args = $#ARGV + 1;
if ($num_args == 1) {
    $ARGV[1] = $ARGV[0];
}
if ($num_args < 1 || $ARGV[0] > $ARGV[1]) {
    die "Starting year cannot be greater than ending year.\n";
}

main($ARGV[0], $ARGV[1]);

sub main {
    print "Hello world!\n";
    my $starting_year = $_[0];
    my $ending_year = $_[1];
    for (my $y = $starting_year; $y <= $ending_year; ++$y) {
        print "Downloading Year $y...";
        downloadFile("http://www.inc.com/inc5000/list/$y/0//.html");

        my $PAGE_COUNT = extractPageCount();
        print "Found $PAGE_COUNT pages. Time to get crack'n boy!\n";

        my $urlend = 0;
        unlink -e "list_$y.csv";
        for (my $count = 1; $count <= $PAGE_COUNT; ++$count) {
            $urlend = ($count * 100) - 100;
            print "[PAGE $count of $PAGE_COUNT] ->\n";
            downloadFile("http://www.inc.com/inc5000/list/$y/$urlend//.html");
            processDownloadedFile($urlend, $y);
        }
    }

    cleanUp();
    print "Done.\n";
}

sub cleanUp {
    print "Cleaning up...";
    unlink "temp.txt";
}
sub downloadFile {
    my $file = $_[0];
    print "Downloading $file...\n";
    my $ff = File::Fetch->new(uri => $file);

    my $where = $ff->fetch() or die $ff->error;

    unlink -e "temp.txt";
    move $ff->output_file, "temp.txt" or die "Could not move file...\n";
}

sub extractPageCount {
    open FILE, "temp.txt" or die $!;
    my $html = do { local $/; <FILE>};
    close (FILE);

    my $dom = Mojo::DOM->new($html);
    my $page_count = $dom->at("span.current_pg")->text;

    $page_count =~ s/.*\W(\w)/$1/;
    $page_count;
}

sub processDownloadedFile {
    my $starting_record = $_[0];
    my $currentyear = $_[1];
    print "+ Processing...\n";
    open FILE, "temp.txt" or die $!;
    my $html = do { local $/; <FILE>};
    close (FILE);

    my $dom = Mojo::DOM->new($html);
    open (MYFILE, ">>list_$currentyear.csv");

    if ($starting_record == 0) {
        print MYFILE "Rank,Company Name,3-Year % Growth,Revenue,Industry,# of Employees,City,State\n";
    }

    my $total = 0;
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
    print "+ Done!\n";
}
