import pandas as pd

from argparse import ArgumentParser

# Parse arguments
parser = ArgumentParser()
parser.add_argument("-file_name", required=True,
                    help="File with original dataset with labels")
parser.add_argument("-path_to_sets", required=True,
                    help="Path where the sets we need the labels for are")
args = parser.parse_args()

# If the path to sets has "/" in its path, remove it for preventing errors in subsequent steps
if args.path_to_sets[-1] == "/":
    args.path_to_sets = args.path_to_sets[:-1]
    
original_dataset = pd.read_csv(args.file_name, delim_whitespace=True, header=None, 
                               names=["ZINC_ID","r_i_docking_score"])

train_set = pd.read_csv(args.path_to_sets + "/train_set.txt", delim_whitespace=True, header=None, names=["ZINC_ID"])
test_set = pd.read_csv(args.path_to_sets + "/test_set.txt", delim_whitespace=True, header=None, names=["ZINC_ID"])
valid_set = pd.read_csv(args.path_to_sets + "/valid_set.txt", delim_whitespace=True, header=None, names=["ZINC_ID"])

merged_train_set = pd.merge(train_set,original_dataset, on='ZINC_ID', how='left')
merged_test_set = pd.merge(test_set,original_dataset, on='ZINC_ID', how='left')
merged_valid_set = pd.merge(valid_set,original_dataset, on='ZINC_ID', how='left')

# Remove compounds(rows) that are not in the given set
merged_train_set = merged_train_set[merged_train_set['r_i_docking_score'].notna()]
labeled_train_set = merged_train_set.reindex(columns=['r_i_docking_score','ZINC_ID'])
# Remove compounds(rows) that are not in the given set
merged_test_set = merged_test_set[merged_test_set['r_i_docking_score'].notna()]
labeled_test_set = merged_test_set.reindex(columns=['r_i_docking_score','ZINC_ID'])
# Remove compounds(rows) that are not in the given set
merged_valid_set = merged_valid_set[merged_valid_set['r_i_docking_score'].notna()]
labeled_valid_set = merged_valid_set.reindex(columns=['r_i_docking_score','ZINC_ID'])

labeled_train_set.to_csv(args.path_to_sets + "/training_labels.txt", index=None, mode='a')
labeled_test_set.to_csv(args.path_to_sets + "/testing_labels.txt", index=None, mode='a')
labeled_valid_set.to_csv(args.path_to_sets + "/validation_labels.txt", index=None, mode='a')
