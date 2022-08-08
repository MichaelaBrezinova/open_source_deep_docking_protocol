import pandas as pd
from os import listdir
from os.path import isfile, join
from argparse import ArgumentParser

# IMPORTANT - Make sure the IDs correspond

# Parse arguments
parser = ArgumentParser()
parser.add_argument("-original_dataset", required=True,
                    help="Path to directory with files to process")
parser.add_argument("-directory_to_compare", required=True,
                    help="Path to directory to compare the file with ")
args = parser.parse_args()

# If directory_to_compare has "/" in its path, remove it for preventing errors in subsequent steps
if args.directory_to_compare[-1] == "/":
    args.directory_to_compare = args.directory_to_compare[:-1]
    
# Load original dataset and drop duplicates
original_dataset = pd.read_csv(args.original_dataset, delim_whitespace=True, header=None, names=["zinc_id","score"])
original_dataset= original_dataset.drop_duplicates(subset="zinc_id")

files_in_directory = [f for f in listdir(args.directory_to_compare) if f.endswith('.txt')]
for file in files_in_directory:
    df = pd.read_csv( args.directory_to_compare + file, 
                     delim_whitespace=True, header=None, names=["smiles", "zinc_id"])
    dataframes.append(df)
library = pd.concat(dataframes, axis=0, ignore_index=True)

merged_results= pd.merge(original_dataset, library, on='zinc_id', how='left')
# Remove compounds(rows) that are not in the library
merged_results = merged_results[merged_results['smiles'].notna()]

filtered_original_dataset = merged_results.drop(['smiles'], axis=1)

# Save filtered original dataset to file
filtered_original_dataset.to_csv(args.original_dataset.split('.')[0] + "_filtered.txt", 
                           header=None, index=None, sep=' ', mode='a')