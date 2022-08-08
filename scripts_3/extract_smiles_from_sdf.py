import re 
import pandas as pd
from os import listdir, makedirs
from os.path import isfile, join, exists
from argparse import ArgumentParser

# Parse arguments
parser = ArgumentParser()
parser.add_argument("-directory_to_process", required=True,
                    help="Path to directory with files to process")
parser.add_argument("-path_to_store", required=True,
                    help="Path to store the processed output file")
args = parser.parse_args()

# If directory to process has "/" in its path, remove it for preventing errors in subsequent steps
if args.directory_to_process[-1] == "/":
    args.directory_to_process = args.directory_to_process[:-1]
if args.path_to_store[-1] == "/":
    args.path_to_store = args.path_to_store[:-1]
    
smiles_and_zincs =[]

# Get all SDF files in the directory 
files_in_directory = [f for f in listdir(args.directory_to_process) if f.endswith('.sdf')]

# Extract ZINC IDs and corresponding smiles for all SDF files
for f in files_in_directory:
    with open(join(args.directory_to_process,f)) as file:
        wake_up = False
        for line in file:
            line  = line.rstrip()
            if line and line[0:4] == "ZINC" and re.match("ZINC\d+(_\d+)?", line.strip()):
                zinc_id = line
            if wake_up:
                smiles = line.strip()
                wake_up=False
            if line and ("smiles" in line):
                wake_up=True
            if line and line[0:4] == "$$$$":
                if(smiles!= "" and  zinc_id!= ""):
                    smiles_and_zincs.append((smiles,zinc_id))
                zinc_id = ""
                smiles = ""

file_name = args.directory_to_process.split('/')[-1]
labeled_smiles = pd.DataFrame(smiles_and_zincs, columns=['smile', 'ZINC_ID'])

# Check whether the specified path exists or not
isExist = exists(args.path_to_store)
if not isExist:
  # Create a new directory for the specified path
    makedirs(args.path_to_store)

labeled_smiles.to_csv(args.path_to_store + "/" + file_name + "_smiles_final_updated.txt", 
                           header=None, index=None, sep=' ', mode='a')