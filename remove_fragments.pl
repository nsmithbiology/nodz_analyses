#!/usr/bin/perl
use strict;
use warnings;

# Check for the correct number of arguments
if (@ARGV != 2) {
    die "Usage: $0 input.fasta output.fasta\n";
}

# Get input and output file names from command line arguments
my ($input_file, $output_file) = @ARGV;

# Open input and output files
open(my $in_fh, '<', $input_file) or die "Could not open input file '$input_file': $!\n";
open(my $out_fh, '>', $output_file) or die "Could not open output file '$output_file': $!\n";

# Initialize variables
my $write_entry = 1;
my $header = '';
my $sequence = '';

while (my $line = <$in_fh>) {
    chomp $line;
    if ($line =~ /^>/) {
        # Write the previous entry if it didn't contain "fragment"
        if ($header && $write_entry) {
            print $out_fh "$header\n$sequence\n";
        }
        # Reset variables for the new entry
        $header = $line;
        $sequence = '';
        # Determine if the current entry should be written
        $write_entry = ($header !~ /fragment/i);
    } else {
        $sequence .= $line if $write_entry;
    }
}

# Write the last entry if it didn't contain "fragment"
if ($header && $write_entry) {
    print $out_fh "$header\n$sequence\n";
}

# Close filehandles
close $in_fh;
close $out_fh;