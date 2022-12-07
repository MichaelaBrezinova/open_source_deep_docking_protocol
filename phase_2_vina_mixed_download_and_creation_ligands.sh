#!/bin/bash

current_iteration=$1
n_cpus_per_node=$2
path_project=$3
project_name=$4
name_cpu_partition=$5
account_name=$6

# Get paths
file_path=`sed -n '1p' $path_project/$project_name/logs.txt`
protein=`sed -n '2p' $path_project/$project_name/logs.txt`

path_to_iteration=$file_path/$protein/iteration_${current_iteration}

# Create directory where to store ligands. Directory is called pdbqt despite us downloading SDFs as we are going to convert
# them later.
pdbqt_directory="pdbqt"
mkdir -p ${path_to_iteration}/$pdbqt_directory  || { echo 'Error creating directory' ; exit 1; }

# Create sets containing only molecules that are not having geometric isomers present
grep -v "_" ${path_to_iteration}/train_set.txt > ${path_to_iteration}/train_set-no-isomers.txt
grep -v "_" ${path_to_iteration}/test_set.txt > ${path_to_iteration}/test_set-no-isomers.txt
grep -v "_" ${path_to_iteration}/valid_set.txt > ${path_to_iteration}/valid_set-no-isomers.txt

# Create sets of smiles containing molecules that have geometric isomers present
grep "_" ${path_to_iteration}/smile/train_smiles_final_updated.smi > ${path_to_iteration}/train_smiles-isomers.smi
grep "_" ${path_to_iteration}/smile/test_smiles_final_updated.smi > ${path_to_iteration}/test_smiles-isomers.smi
grep "_" ${path_to_iteration}/smile/valid_smiles_final_updated.smi > ${path_to_iteration}/valid_smiles-isomers.smi

#### DO DOWNLOAD FOR ALL MOLECULES THAT ARE NOT HAVING ISOMERS ####
# For each file of form (*_set_no_isomers.txt) [* = train/test/valid] perform 
# the download of sdfs for all ZINC IDs contained in them
echo "Downloading ligands for molecules that do not have geometric isomers"
for f in ${path_to_iteration}/*_set-no-isomers.txt
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%_*}" # train/test/validation
   
   mkdir -p ${path_to_iteration}/${pdbqt_directory}/${set_type}_download || { echo 'Error creating directory' ; exit 1; }
   mkdir -p ${path_to_iteration}/${set_type}_set_scripts || { echo 'Error creating directory' ; exit 1; }
   
   # Create scripts to download SDFs of chunks of size 1000
   python scripts_3/create_download_ligand_scripts.py -file $f -path_to_store_scripts ${path_to_iteration}/${set_type}_set_scripts -path_to_store_ligands ${path_to_iteration}/${pdbqt_directory}/${set_type}_download

   # Run separate download job for each batch of 1000
   for f in ${path_to_iteration}/${set_type}_set_scripts/*.sh;
   do dos2unix $f;sbatch -N 1 -n 1 --time=00:30:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition $f;
   done
done

#### CREATE LIGANDS FOR ALL MOLECULES THAT ARE HAVING ISOMERS ####
# For each file that contains the smiles for specific dataset (train/test/validation), split the file into chunks of 1000 and generate 3D conformations
echo "Creating ligands for molecules with geometric isomers"
for f in ${path_to_iteration}/*_smiles-isomers.smi
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%%_*}" # train/test/validation
   
   # Create directory that will contain ligands for the specific set (train/test/validation)
   mkdir -p ${path_to_iteration}/${pdbqt_directory}/${set_type}_creation || { echo 'Error creating directory' ; exit 1; }
   
   # Split the file containing smiles into chunks of 1000
   split -l 1000 $f ${path_to_iteration}/${pdbqt_directory}/${set_type}_creation/chunk_
   
   # Run the 3D conformation tool for each of the chunks in parallel
   for file_with_smiles in ${path_to_iteration}/${pdbqt_directory}/${set_type}_creation/*
   do
       echo "create job for ${file_with_smiles}" 
       # Parameters set for slurm come from the user's input. However, if there are specific cluster requirements/changes needed
       # please add them here.
       sbatch -N 1 -n 1 --time=10:00:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition --wrap "python scripts_3/smi2sdf.py -n 1 -j $n_cpus_per_node -i $file_with_smiles -o $file_with_smiles.sdf;"
   done 
done
