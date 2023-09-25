#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --account=VENDRUSCOLO-SL3-GPU
#SBATCH --partition ampere
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --job-name=phase_3
#SBATCH --time=01:00:00

# PARAMETERS
folder=$1
use_vina_gpu=$2
account_name=$3
partition=$4
configuration_file=$5
receptor=$6
vina_path=$7


# Establish paths used in docking for inputs (pdbqt directory) and outputs (docked directory)
mkdir -p ${folder}/docked
path_to_pdbqt=${folder}/pdbqt
path_to_docked=${folder}/docked

# For each set (creation/download) directory, create a matching directory in docked (output) directory and run batches within 
# each directory as a separate job.
for d in ${path_to_pdbqt}/*;
do
    tmp="$d"
    directory_set_name="${tmp##*/}"
    echo "Processing PDBQTs in ${directory_set_name}"
    # Create matching directory in docked (output) directory
    mkdir -p ${path_to_docked}/${directory_set_name} || { echo 'Creating directory failed' ; exit 1; }
    # For each batch within directory, run a separate docking job
    for batch in $d/*/
    do
        tmp="$batch"
        trimmed_batch="${tmp%/}"
        echo "Processing ${trimmed_batch} with output directory ${path_to_docked}/${directory_set_name}" 
        sbatch --account $account_name --partition $partition ../scripts_3/run_batch_docking.sh ${trimmed_batch} $receptor $configuration_file ${path_to_docked}/${directory_set_name} $vina_path "$use_vina_gpu"
    done
done
