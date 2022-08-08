import pandas as pd
import random
from argparse import ArgumentParser

# Parse arguments (file to process, directory to store)
parser = ArgumentParser()
parser.add_argument("-file_to_process", required=True,
                    help="File to process of form ZINC_ID docking_score, separated by space and no header")
parser.add_argument("-path_to_store", required=True,
                    help="Path to store the processed output file")
args = parser.parse_args()

# Load original dataset
original_dataset = pd.read_csv(args.file_to_process, delim_whitespace=True, header=None, 
                               names=["ZINC_ID","r_i_docking_score"])

zinc_ids = list(original_dataset["ZINC_ID"])
random.shuffle(zinc_ids)
train,test,valid = [zinc_ids[i::3] for i in range(3)]

with open( args.path_to_store + '/train_set.txt', 'w') as f:
    for item in train:
        f.write("%s\n" % item)

with open(args.path_to_store + '/test_set.txt', 'w') as f:
    for item in test:
        f.write("%s\n" % item)

with open(args.path_to_store + '/valid_set.txt', 'w') as f:
    for item in valid:
        f.write("%s\n" % item)