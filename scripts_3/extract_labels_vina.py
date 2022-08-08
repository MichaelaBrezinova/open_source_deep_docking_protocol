import pandas  as  pd
from os import listdir
from os.path import isfile, join
from argparse import ArgumentParser

# Parse arguments (directory to files to process)
parser = ArgumentParser()
parser.add_argument("-directory_to_process", required=True,
                    help="Path to directory with files to process")
parser.add_argument("-path_to_store", required=True,
                    help="Path to store the processed output file")
args = parser.parse_args()

# List that will hold labeled zincs of form (binding_affinity,zinc_id)
labeled_zincs =[]

# Process each file in the directory
files_to_process = [f for f in listdir(args.directory_to_process) if isfile(join(args.directory_to_process, f))]
for f in files_to_process:
    with open(join(args.directory_to_process,f)) as file:
        wake_up = False
        # Iterate over lines
        for line in file:
            line  = line.rstrip()
            if line and line[0:4] == "ZINC":
                zinc_id = line
            if wake_up:
                line_list = line.split()
                binding_affinity = line_list[1]
                wake_up=False
            # If encountered "-----", wake up as the next line will have binding affinity
            if line and line[0:5] == "-----":
                wake_up=True
            # If encountered end of entry ("@@@@"), append the affinity-zinc_id pair to the list. If no affinity was found
            # (there was docking issue), do not add it to the list.
            if line and line[0:4] == "@@@@":
                if(binding_affinity != ""):
                    labeled_zincs.append((binding_affinity,zinc_id))
                # Restart value of zinc_id and binding_affinity for next entry
                zinc_id = ""
                binding_affinity = ""

# Create dataframe from the labeled_zincs list
labeled_zincs_dataframe = pd.DataFrame(labeled_zincs, columns=['r_i_docking_score', 'ZINC_ID'])
# Extract name of processed directory
processed_directory_name = args.directory_to_process.split('/')[-1]
# Store the labeled zincs into a text file
if(processed_directory_name == "test"):
    file_name = "testing_labels.txt"
elif (processed_directory_name == "valid"):
    file_name = "validation_labels.txt"
elif (processed_directory_name == "train"):
    file_name = "training_labels.txt"
else:
    file_name = processed_directory_name + "_labels.txt"
labeled_zincs_dataframe.to_csv( args.path_to_store + "/" + file_name, index=None, mode='a')