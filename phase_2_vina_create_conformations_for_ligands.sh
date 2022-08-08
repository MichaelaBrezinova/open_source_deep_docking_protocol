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

# For each file that contains the smiles for specific dataset (train/test/validation), split the file into chunks of 1000 and generate 3D conformations
for f in ${path_to_iteration}/smile/*
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%%_*}" # train/test/validation
   
   # Create directory that will contain ligands for the specific set (train/test/validation)
   mkdir -p ${path_to_iteration}/${pdbqt_directory}/${set_type} || { echo 'Error creating directory' ; exit 1; }
   
   # Split the file containing smiles into chunks of 1000
   split -l 1000 $f ${path_to_iteration}/${pdbqt_directory}/${set_type}/chunk_
   
   # Run the 3D conformation tool for each of the chunks in parallel
   for file_with_smiles in ${path_to_iteration}/${pdbqt_directory}/${set_type}/*
   do
       # Parameters set for slurm come from the user's input. However, if there are specific cluster requirements/changes needed
       # please add them here.
       sbatch -N 1 -n 1 --time=05:00:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition --wrap "python scripts_3/smi2sdf.py -n 1 -j $n_cpus_per_node -i $file_with_smiles -o $file_with_smiles.sdf; rm $file_with_smiles"
   done 
done
