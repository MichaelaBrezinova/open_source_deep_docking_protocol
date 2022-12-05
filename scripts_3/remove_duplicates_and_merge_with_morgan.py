import pandas as pd
from argparse import ArgumentParser

# Note - code assumes numerical indexing of files of format <smiles_input_directory>/smiles_all_<index>.txt  and <fingerprints_input_directory>/smiles_all_<index>.txt and compounds in the indexed files corresponding.

parser = ArgumentParser()

parser.add_argument("-input_directory_smiles", required=True,
                    help="Smiles input directory")
parser.add_argument("-input_directory_fingerprints", required=True,
                    help="Fingerprints input directory")
parser.add_argument("-output_directory_smiles", required=True,
                    help="Smiles output directory")
parser.add_argument("-output_directory_fingerprints", required=True,
                    help="Fingerprints output directory")
parser.add_argument("-start_file", type=int, default=0,
                    help="The start file to process (has to be number)")
parser.add_argument("-end_file", type=int, default=99,
                    help="The end file to process (has to be number)")

args = parser.parse_args()

print("Processing files " + str(args.start_file) + " to " + str(args.end_file))

file_numbers = list(range(args.start_file, args.end_file+1))
for file_number in file_numbers:
    print("Processing file " + str(file_number))
    # process smiles files
    smiles_file = pd.read_csv(args.input_directory_smiles + "/smiles_all_" + "{0:0=2d}".format(file_number) + ".txt",
                              delim_whitespace=True, header=None, names=["smiles", 'zinc_id'])
    
    # process fingerprints file
    fingerprints_file = pd.read_csv(args.input_directory_fingerprints + "/smiles_all_" + "{0:0=2d}".format(file_number) + ".txt", 
                                sep='^([^,]+),', engine='python', header=None, 
                                names=['to_remove', 'zinc_id', 'morgan'])
    fingerprints_file.drop('to_remove', inplace=True, axis=1)
    
    if(smiles_file.shape[0]>0):
        # Remove _{number} extension for compounds that are only once in the database
        smiles_file["short_zinc_id"] = smiles_file["zinc_id"].str.split('_', expand=True).iloc[:, 0]
        smiles_file["clean_zinc_id"] = smiles_file["zinc_id"]
        smiles_only_once= [not elem for elem in smiles_file.duplicated(subset="short_zinc_id", keep=False)]
        smiles_file.loc[smiles_only_once, 'clean_zinc_id'] = smiles_file.loc[smiles_only_once, 
                                                                             'clean_zinc_id'].str.split('_',expand=True).iloc[:, 0]

        # remove duplicates
        smiles_file_filtered = smiles_file.drop_duplicates(subset="clean_zinc_id")
        fingerprints_file_filtered  = fingerprints_file.drop_duplicates(subset="zinc_id")

        # merge the two dataframes on ZINC ID
        merged_result = smiles_file_filtered.merge(fingerprints_file_filtered, on='zinc_id')
        
        # retrieve back new smiles and fingerprints dataframes
        new_smiles_file = merged_result.drop(['morgan','zinc_id','short_zinc_id'], axis=1)
        new_fingerprints_file = merged_result.drop(['smiles','zinc_id','short_zinc_id'], axis=1)
    else:
        # remove duplicates
        smiles_file_filtered = smiles_file.drop_duplicates(subset="zinc_id")
        fingerprints_file_filtered  = fingerprints_file.drop_duplicates(subset="zinc_id")
        
        # merge the two dataframes on ZINC ID
        merged_result = smiles_file_filtered.merge(fingerprints_file_filtered, on='zinc_id')
    
        # retrieve back new smiles and fingerprints dataframes
        new_smiles_file = merged_result.drop(['morgan'], axis=1)
        new_fingerprints_file = merged_result.drop(['smiles'], axis=1)
    
    # save new smiles and fingerprints dataframes
    new_smiles_file.to_csv(args.output_directory_smiles + "/smiles_all_" + "{0:0=2d}".format(file_number) + ".txt", 
                           header=None, index=None, sep=' ', mode='a')
    
    new_fingerprints_file.to_csv(args.output_directory_fingerprints + "/smiles_all_" + "{0:0=2d}".format(file_number) + ".txt", 
                                 header=None, index=None, sep='?')
    
    
    
    