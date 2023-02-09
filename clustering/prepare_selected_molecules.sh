#!/bin/bash

folder=$1
n_cpus_per_node=$2
name_cpu_partition=$3
account_name=$4

# Create directory where to store ligands. Directory is called pdbqt despite us downloading SDFs as we are going to convert
# them later.
pdbqt_directory="pdbqt"
mkdir -p ${folder}/$pdbqt_directory  || { echo 'Error creating directory' ; exit 1; }


#### DO DOWNLOAD FOR ALL MOLECULES THAT ARE NOT HAVING ISOMERS ####
# For each file of form (*-no-isomers.txt) [* = clusters/singletons] perform 
# the download of sdfs for all ZINC IDs contained in them
echo "Downloading ligands for molecules that do not have geometric isomers"
for f in ${folder}/singletons-no-isomers.txt
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%%-*}" # clusters/singletons
   
   mkdir -p ${folder}/${pdbqt_directory}/${set_type}_download || { echo 'Error creating directory' ; exit 1; }
   mkdir -p ${folder}/${set_type}_set_scripts || { echo 'Error creating directory' ; exit 1; }
   
   # Create scripts to download SDFs of chunks of size 1000
   python ../scripts_3/create_download_ligand_scripts.py -file $f -path_to_store_scripts ${folder}/${set_type}_set_scripts -path_to_store_ligands ${folder}/${pdbqt_directory}/${set_type}_download

   # Run separate download job for each batch of 1000
   for f in ${folder}/${set_type}_set_scripts/*.sh;
   do dos2unix $f;sbatch -N 1 -n 1 --time=00:30:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition $f;
   done
done

#### CREATE LIGANDS FOR ALL MOLECULES THAT ARE HAVING ISOMERS ####
# For each file that contains the smiles for specific dataset (clusters/singletons), split the file into chunks of 1000 and generate 3D conformations
echo "Creating ligands for molecules with geometric isomers"
for f in ${folder}/singletons-isomers.smi
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%%-*}" # clusters/singletons
   
   # Create directory that will contain ligands for the specific set (clusters/singletons)
   mkdir -p ${folder}/${pdbqt_directory}/${set_type}_creation || { echo 'Error creating directory' ; exit 1; }
   
   # Split the file containing smiles into chunks of 1000
   split -l 1000 $f ${folder}/${pdbqt_directory}/${set_type}_creation/chunk_
   
   # Run the 3D conformation tool for each of the chunks in parallel
   for file_with_smiles in ${folder}/${pdbqt_directory}/${set_type}_creation/*
   do
       echo "create job for ${file_with_smiles}" 
       # Parameters set for slurm come from the user's input. However, if there are specific cluster requirements/changes needed
       # please add them here.
       sbatch -N 1 -n 1 --time=10:00:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition --wrap "python ../scripts_3/smi2sdf.py -n 1 -j $n_cpus_per_node -i $file_with_smiles -o $file_with_smiles.sdf;"
   done 
done


