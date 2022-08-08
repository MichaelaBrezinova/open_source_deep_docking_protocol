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

# For each file of form (*_set.txt) [* = train/test/validation] perform 
# the download of sdfs for all ZINC IDs contained in them
for f in ${path_to_iteration}/*_set.txt
do
   tmp="$f"
   filename="${tmp##*/}"
   set_type="${filename%_*}" # train/test/validation
   
   mkdir -p ${path_to_iteration}/${pdbqt_directory}/${set_type} || { echo 'Error creating directory' ; exit 1; }
   mkdir -p ${path_to_iteration}/${set_type}_set_scripts || { echo 'Error creating directory' ; exit 1; }
   
   # Create scripts to download SDFs of chunks of size 1000
   python scripts_3/create_download_ligand_scripts.py -file $f -path_to_store_scripts ${path_to_iteration}/${set_type}_set_scripts -path_to_store_ligands ${path_to_iteration}/${pdbqt_directory}/${set_type}

   # Run separate download job for each batch of 1000
   for f in ${path_to_iteration}/${set_type}_set_scripts/*.sh;
   do dos2unix $f;sbatch -N 1 -n 1 --time=00:10:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition $f;
   done
done
