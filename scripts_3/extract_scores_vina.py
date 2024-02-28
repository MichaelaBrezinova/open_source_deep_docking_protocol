import pandas  as  pd
from os import listdir
from os.path import isfile, join
from argparse import ArgumentParser

def extract_scores_from_one_file(directory, f):
    scored_zincs = []
    binding_affinity=""
    zinc_id=""
    with open(join(directory,f)) as file:
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
                # If encountered end of entry ("@@@@"), append the affinity-zinc_id pair to the list. 
                # If no affinity was found (there was docking issue), do not add it to the list.
                if line and line[0:4] == "@@@@":
                    if(binding_affinity != ""):
                        scored_zincs.append((binding_affinity,zinc_id))
                    # Restart value of zinc_id and binding_affinity for next entry
                    zinc_id = ""
                    binding_affinity = ""
    return scored_zincs

# Function that processes directory and extract zinc-id -- binding affinity pairs
def extract_scores(directories_to_process):

    # List that will hold scored zincs of form (binding_affinity,zinc_id)
    all_scored_zincs =[]

    for directory in directories_to_process: 
        # Process each file in the download directory
        files_to_process = [f for f in listdir(directory) if isfile(join(directory, f))]
        for f in files_to_process:
            print("Processing file ", f)
            scored_zincs = extract_scores_from_one_file(directory, f)
            all_scored_zincs.extend(scored_zincs)               

    # Create dataframe from the scored_zincs list
    scored_zincs_dataframe = pd.DataFrame(scored_zincs, columns=['r_i_docking_score', 'ZINC_ID'])
   
    return scored_zincs_dataframe

def main():
    # Parse arguments (directory to files to process)
    parser = ArgumentParser()
    parser.add_argument("-directory_to_process", required=True,
                        help="Directory with files to process. If doing download-creation extension split, this should be prefix to both directories.")
    parser.add_argument("-path_to_store", required=True,
                        help="Path to store the processed output file")
    parser.add_argument("-do_download_creation_extension_split", type=bool, default=False,
                        help="Whether to add download/creation name extension to the directory")
    args = parser.parse_args()

    if(args.do_download_creation_extension_split):
        # For the prefix, there is download and creation directory 
        print('Doing download/creation split')
        download_directory = args.directory_to_process + "_download"
        creation_directory = args.directory_to_process + "_creation"
        directories_to_process = [download_directory, creation_directory]  
    else:  
        print('NOT doing download/creation split')  
        directories_to_process = [args.directory_to_process]

    # Extract labels into file
    scored_zincs_dataframe = extract_scores(directories_to_process)

    # Extract singular name of processed directory
    processed_directory_name = args.directory_to_process.split('/')[-1]
    # Store the scored zincs into a text file
    if(processed_directory_name == "test"):
        file_name = "testing_labels.txt"
    elif (processed_directory_name == "valid"):
        file_name = "validation_labels.txt"
    elif (processed_directory_name == "train"):
        file_name = "training_labels.txt"
    else:
        file_name = processed_directory_name + "_labels.txt"

    scored_zincs_dataframe.to_csv(args.path_to_store + "/" + file_name, index=None, mode='a')

if __name__ == "__main__":
    main()