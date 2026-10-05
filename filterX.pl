#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

# Check for the correct number of command-line arguments
if (@ARGV != 2) {
    die "Usage: $0 <input.fasta> <output.fasta>\n";
}

# Input and output file paths
my $input_file = shift @ARGV;
my $output_file = shift @ARGV;

# Create Bio::SeqIO objects for reading and writing FASTA files
my $in = Bio::SeqIO->new(-file => $input_file, -format => 'fasta');
my $out = Bio::SeqIO->new(-file => ">$output_file", -format => 'fasta');

# Initialize array to store identifiers of removed sequences
my @removed_entries;

# Iterate through each sequence in the input file
while (my $seq = $in->next_seq()) {
    # Check if the sequence contains "X"
    if ($seq->seq() =~ /X/) {
        # Store the identifier of the sequence with "X"
        push @removed_entries, $seq->display_id();
    } else {
        # Write the sequence to the output file if it doesn't contain "X"
        $out->write_seq($seq);
    }
}

# Print identifiers of removed sequences
if (@removed_entries) {
    print "The following entries were removed:\n";
    print join("\n", @removed_entries), "\n";
} else {
    print "No sequences containing 'X' were found and removed.\n";
}