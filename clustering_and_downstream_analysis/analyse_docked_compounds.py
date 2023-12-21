#!/usr/bin/python

import sys
sys.path.insert(0,"../scripts_3")
from extract_scores_vina import extract_scores
import pandas  as  pd
import os, fnmatch
from argparse import ArgumentParser

# Helper function to convert the molecule to path to it
def convert_to_filename(zinc_id, path_to_molecules):
    if "_" in zinc_id:
        return path_to_molecules + "/clusters_creation/" + zinc_id + "_out.pdbqt"
    else:
        return path_to_molecules + "/clusters_download/" + zinc_id + "_out.pdbqt"

# # Helper function to find the molecule's docking output file
# def find(pattern, path):
#     result = []
#     for root, dirs, files in os.walk(path):
#         for name in files:
#             if fnmatch.fnmatch(name, pattern):
#                 result.append(os.path.join(root, name))
#     return result

def get_selected_molecules(directories_to_process, number_of_molecules_to_extract, path_to_molecules):
    
    # Get labels and corresponding ZINC_IDs
    full_labels = extract_scores(directories_to_process)
    full_labels["r_i_docking_score"] = pd.to_numeric(full_labels["r_i_docking_score"])
    labels = full_labels.sort_values(by="r_i_docking_score").head(int(number_of_molecules_to_extract))
    labels["file"] = labels.apply(lambda x: convert_to_filename(x['ZINC_ID'], path_to_molecules), axis=1)
    return [full_labels, labels]

def main():
    # Parse arguments (directory to files to process)
    parser = ArgumentParser()
    parser.add_argument("-directory_prefix_to_process", required=True,
                        help="Directory prefix for directories (creation and download) with files to process")
    parser.add_argument("-path_to_store", required=True,
                        help="Path to store the processed output file")
    parser.add_argument("-path_to_molecules", required=True,
                        help="Path to where the output molecules from docking are stored")
    parser.add_argument("-number_of_molecules_to_extract", default=100000, 
                        help="Number of best scoring molecules to extract")
    args = parser.parse_args()

    # For each prefix, there is download and creation directory 
    download_directory = args.directory_prefix_to_process + "_download"
    creation_directory = args.directory_prefix_to_process + "_creation"
    directories_to_process = [download_directory, creation_directory]

    # Extract selected molecules and paths to their docking output files
    results = get_selected_molecules(directories_to_process, 
                                                args.number_of_molecules_to_extract,
                                                args.path_to_molecules)

    # Extract singular name of processed directory
    processed_directory_name = args.directory_prefix_to_process.split('/')[-1]
    
    # Store the molecules and their paths to a file
    full_labels_file_name = processed_directory_name + "_labels.txt"
    results[0].to_csv(args.path_to_store + "/" + full_labels_file_name, index=None, mode='a')

    # Store the molecules and their paths to a file
    labels_file_name = processed_directory_name + "_selected_molecules.txt"
    results[1].to_csv(args.path_to_store + "/" + labels_file_name, index=None, mode='a')

if __name__ == "__main__":
    main()
