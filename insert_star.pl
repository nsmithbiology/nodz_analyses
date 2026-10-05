#!/usr/bin/perl
use strict;
use warnings;

# Check for correct number of arguments
if (@ARGV != 3) {
    die "Usage: $0 <input_alignment_file> <output_alignment_file> <position>\n";
}

# Read command-line arguments
my ($input_file, $output_file, $position) = @ARGV;

# Open input file for reading
open(my $in_fh, '<', $input_file) or die "Cannot open $input_file: $!";

# Open output file for writing
open(my $out_fh, '>', $output_file) or die "Cannot open $output_file: $!";

# Initialize variables
my ($current_id, $sequence_lines);

# Process each line in the input file
while (my $line = <$in_fh>) {
    chomp $line;
    if ($line =~ /^>/) {
        # If $current_id has a value (not the first sequence), process and print the previous sequence
        if ($current_id) {
            my $modified_sequence = insert_character_at_position($sequence_lines, $position, '*');
            print $out_fh ">$current_id\n$modified_sequence\n";
        }
        # Set new sequence ID
        ($current_id, $sequence_lines) = ($line =~ /^>(\S+)\s*(.*)/);
    } else {
        # Append the sequence line (handling potential indentation)
        $sequence_lines .= $line;
    }
}

# Don't forget to process the last sequence in the file
if ($current_id) {
    my $modified_sequence = insert_character_at_position($sequence_lines, $position, '*');
    print $out_fh ">$current_id\n$modified_sequence\n";
}

# Close filehandles
close($in_fh);
close($out_fh);

# Function to insert a character at a specific position in a string
sub insert_character_at_position {
    my ($string, $pos, $char) = @_;
    my $before = substr($string, 0, $pos - 1);
    my $after = substr($string, $pos - 1);
    return $before . $char . $after;
}