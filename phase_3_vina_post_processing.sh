# PARAMETERS
path_to_iteration=$1

#### CORRECTING SMILES AND MORGAN FINGERPRINTS #### 

# DOWNLOADED COMPOUNDS - Extract smiles from the SDFs for the downloaded compounds
echo "processing download directories and extracting smiles"
mkdir ${path_to_iteration}/corrected_smile
mkdir ${path_to_iteration}/corrected_morgan

# Valid set
echo "processing valid"
python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/valid_download -path_to_store ${path_to_iteration}/corrected_smile

# Train set
echo "processing train"
python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/train_download -path_to_store ${path_to_iteration}/corrected_smile

# Test set
echo "processing test"
python scripts_3/extract_smiles_from_sdf.py -directory_to_process ${path_to_iteration}/pdbqt/test_download -path_to_store ${path_to_iteration}/corrected_smile

mv ${path_to_iteration}/corrected_smile/valid_download_smiles_final_updated.txt  ${path_to_iteration}/corrected_smile/valid_smiles_final_updated.txt  || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_smile/train_download_smiles_final_updated.txt  ${path_to_iteration}/corrected_smile/train_smiles_final_updated.txt || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_smile/test_download_smiles_final_updated.txt  ${path_to_iteration}/corrected_smile/test_smiles_final_updated.txt || { echo 'Trouble renaming' ; exit 1; }

# Prepare relevant morgan fingerprints
echo "preparing fingerprints"
python utilities/morgan_fp.py -sfp ${path_to_iteration}/corrected_smile -fn ${path_to_iteration}/corrected_morgan  -tp 1

# Correct the names of the files so they match with what is expected with later steps
mv ${path_to_iteration}/corrected_smile/valid_smiles_final_updated.txt  ${path_to_iteration}/corrected_smile/valid_smiles_final_updated.smi  || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_smile/train_smiles_final_updated.txt  ${path_to_iteration}/corrected_smile/train_smiles_final_updated.smi || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_smile/test_smiles_final_updated.txt ${path_to_iteration}/corrected_smile/test_smiles_final_updated.smi || { echo 'Trouble renaming' ; exit 1; }

mv ${path_to_iteration}/corrected_morgan/test_smiles_final_updated.txt ${path_to_iteration}/corrected_morgan/test_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_morgan/train_smiles_final_updated.txt ${path_to_iteration}/corrected_morgan/train_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_morgan/valid_smiles_final_updated.txt ${path_to_iteration}/corrected_morgan/valid_morgan_1024_updated.csv || { echo 'Trouble renaming' ; exit 1; }

# CREATED COMPOUNDS

# Get smiles for molecules that have geometric isomers present
grep "_" ${path_to_iteration}/smile/train_smiles_final_updated.smi >> ${path_to_iteration}/corrected_smile/train_smiles_final_updated.smi || { echo 'Trouble appending' ; exit 1; }
grep "_" ${path_to_iteration}/smile/test_smiles_final_updated.smi >> ${path_to_iteration}/corrected_smile/test_smiles_final_updated.smi || { echo 'Trouble appending' ; exit 1; }
grep "_" ${path_to_iteration}/smile/valid_smiles_final_updated.smi >> ${path_to_iteration}/corrected_smile/valid_smiles_final_updated.smi || { echo 'Trouble appending' ; exit 1; }

# Get morgan fingerprints for molecules that have geometric isomers present
grep "_" ${path_to_iteration}/morgan/train_morgan_1024_updated.csv >> ${path_to_iteration}/corrected_morgan/train_morgan_1024_updated.csv || { echo 'Trouble appending' ; exit 1; }
grep "_" ${path_to_iteration}/morgan/test_morgan_1024_updated.csv >> ${path_to_iteration}/corrected_morgan/test_morgan_1024_updated.csv || { echo 'Trouble appending' ; exit 1; }
grep "_" ${path_to_iteration}/morgan/valid_morgan_1024_updated.csv >> ${path_to_iteration}/corrected_morgan/valid_morgan_1024_updated.csv || { echo 'Trouble appending' ; exit 1; }

echo "moving and renaming directories"
mv ${path_to_iteration}/smile ${path_to_iteration}/old_smile || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/morgan ${path_to_iteration}/old_morgan || { echo 'Trouble renaming' ; exit 1; }

mv ${path_to_iteration}/corrected_smile ${path_to_iteration}/smile || { echo 'Trouble renaming' ; exit 1; }
mv ${path_to_iteration}/corrected_morgan ${path_to_iteration}/morgan || { echo 'Trouble renaming' ; exit 1; }

####  EXTRACTING VINA LABELS #### 

# Valid set
python scripts_3/extract_labels_vina.py -directory_prefix_to_process ${path_to_iteration}/docked/valid -path_to_store ${path_to_iteration}

# Test set
python scripts_3/extract_labels_vina.py -directory_prefix_to_process ${path_to_iteration}/docked/test -path_to_store ${path_to_iteration}

# Train set
python scripts_3/extract_labels_vina.py -directory_prefix_to_process ${path_to_iteration}/docked/train -path_to_store  ${path_to_iteration}
