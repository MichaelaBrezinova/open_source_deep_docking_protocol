#!/bin/bash

path_to_iteration=$1

# # Extract smiles from SDFs
# echo "processing directories and extracting smiles"
# # Valid set
# echo "processing valid"
# python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/valid -path_to_store ${path_to_iteration}/corrected_smile
# # Train set
# echo "processing train"
# python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/train -path_to_store ${path_to_iteration}/corrected_smile
# # Test set
# echo "processing test"
# python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/test -path_to_store ${path_to_iteration}/corrected_smile

# echo "preparing fingerprints"
# # Prepare relevant morgan fingerprints
# python utilities/morgan_fp.py -sfp ${path_to_iteration}/corrected_smile -fn ${path_to_iteration}/corrected_morgan  -tp 1

echo "moving and renaming directories"
mv ${path_to_iteration}/smile ${path_to_iteration}/old_smile || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/morgan ${path_to_iteration}/old_morgan || { echo 'Trouble renaming' ; exit 1; }

mv ${path_to_iteration}/corrected_smile ${path_to_iteration}/smile || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_morgan ${path_to_iteration}/morgan || { echo 'Trouble renaming' ; exit 1; }

mv ${path_to_iteration}/smile/test_smiles_final_updated.txt ${path_to_iteration}/smile/test_smiles_final_updated.smi || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/smile/train_smiles_final_updated.txt ${path_to_iteration}/smile/train_smiles_final_updated.smi || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/smile/valid_smiles_final_updated.txt ${path_to_iteration}/smile/valid_smiles_final_updated.smi || { echo 'Trouble renaming' ; exit 1; }


mv ${path_to_iteration}/morgan/test_smiles_final_updated.txt ${path_to_iteration}/morgan/test_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/morgan/train_smiles_final_updated.txt ${path_to_iteration}/morgan/train_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/morgan/valid_smiles_final_updated.txt ${path_to_iteration}/morgan/valid_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }