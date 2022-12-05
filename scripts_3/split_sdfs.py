import pandas  as  pd
import re
from argparse import ArgumentParser

# Parse the arguments
parser = ArgumentParser()
parser.add_argument("-file", required=True,
                    help="File to process")
parser.add_argument("-path_to_store", default="",
                    help="Path to store individual SDFs")
args = parser.parse_args()

# Read the file as a string to content variable
with open(args.file) as f:
    content = f.read()

# Symbol on which the file should be split, as each SDF ends with $$$$, this is a symbol we split at
split_symbol = "$$$$\n"

# Split content on the symbol. This will give us list of strings representing individual SDFs
sdf_strings =  [one_part+split_symbol for one_part in content.split(split_symbol) if one_part]

# Find ZINC ids corresponding to individual SDFs.
ZINC_ids = []
for sdf_string in sdf_strings:
    # Find ZINC ID in the string. 
    zinc_id = re.search("ZINC\d+(_\d+)?", sdf_string).group()
    ZINC_ids.append(zinc_id)

# Store each sdf string into a separate SDF file. File is named by ZINC ID of compound the SDF represents.
for index,sdf_string in enumerate(sdf_strings):
    with open ( args.path_to_store + '/' + ZINC_ids[index] + '.sdf', 'w') as sdf:
        sdf.write(sdf_string)