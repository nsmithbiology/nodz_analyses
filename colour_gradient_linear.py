import sys
from matplotlib import cm, colors
import numpy as np

def normalize(value, min_value, max_value):
    return (value - min_value) / (max_value - min_value)

def value_to_color(value, colormap, min_value, max_value):
    # Linearly scale the value between 0 and 1
    normalized_value = normalize(value, min_value, max_value)
    rgba_color = colormap(normalized_value)
    hex_color = colors.rgb2hex(rgba_color)
    return hex_color

# Check if the correct number of command-line arguments is provided
if len(sys.argv) != 2:
    print("Usage: python rmsd_to_hex.py <input_file>")
    sys.exit(1)

# Input file specified in the command-line arguments
input_file = sys.argv[1]

# Read RMSD values from input file
with open(input_file, 'r') as file:
    lines = file.readlines()

# Extract RMSD values
rmsd_values = []
accessions = []
for line in lines:
    parts = line.strip().split()
    if len(parts) == 2:
        try:
            rmsd = float(parts[0])
            rmsd_values.append(rmsd)
            accessions.append(parts[1])
        except ValueError:
            print(f"Warning: Skipping line due to invalid RMSD value: {line.strip()}")

# Ensure there are values to process
if not rmsd_values:
    print("No valid RMSD values found in the input file.")
    sys.exit(1)

# Find min and max RMSD values
min_value = min(rmsd_values)
max_value = max(rmsd_values)

# Choose a colormap
colormap = cm.get_cmap('viridis')

# Convert RMSD values to hex colors
color_mapping = {}
for rmsd, accession in zip(rmsd_values, accessions):
    hex_color = value_to_color(rmsd, colormap, min_value, max_value)
    color_mapping[accession] = hex_color

# Prepare the results for output
output_lines = [f"{accession} {hex_color}\n" for accession, hex_color in color_mapping.items()]

# Write the results to stdout (which can be redirected)
sys.stdout.writelines(output_lines)