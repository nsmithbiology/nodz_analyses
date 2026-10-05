#!/usr/bin/perl
use strict;
use warnings;

# Check for proper number of command line arguments
if (@ARGV != 2) {
    die "Usage: $0 <input_fasta> <output_fasta>\n";
}

# Assign command line arguments to variables
my ($input_fasta, $output_fasta) = @ARGV;

# Open the input and output files
open(my $infile, '<', $input_fasta) or die "Could not open file '$input_fasta' $!";
open(my $outfile, '>', $output_fasta) or die "Could not open file '$output_fasta' $!";

# Process the input file line by line
while (my $line = <$infile>) {
    if ($line =~ /^>/) {
        my @header_parts = split(' ', $line);
        print $outfile "$header_parts[0]\n";
    } else {
        print $outfile $line;
    }
}

# Close the input and output files
close($infile);
close($outfile);

print "Headers modified and output written to $output_fasta\n";