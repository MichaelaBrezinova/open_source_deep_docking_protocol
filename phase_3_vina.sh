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
current_iteration=$1
path_project=$2
project_name=$3
use_vina_gpu=$4
account_name=$5
partition=$6

# Get paths
file_path=`sed -n '1p' $path_project/$project_name/logs.txt`
protein=`sed -n '2p' $path_project/$project_name/logs.txt`
configuration_file=`sed -n '3p' $path_project/$project_name/logs.txt`
receptor=`sed -n '9p' $path_project/$project_name/logs.txt`

# If using VINA-GPU, get path for VINA-GPU. Otherwise get path for Vina
if [ "$use_vina_gpu" = true ] ; then
    vina_path=`sed -n '12p' $path_project/$project_name/logs.txt`;
else 
    vina_path=`sed -n '11p' $path_project/$project_name/logs.txt`
fi

python jobid_writer.py -pt $protein -fp $file_path -n_it ${current_iteration} -jid phase_3 -jn phase_3.txt

# Establish paths used in docking for inputs (pdbqt directory) and outputs (docked directory)
path_to_iteration=$file_path/$protein/iteration_${current_iteration}
mkdir -p ${path_to_iteration}/docked

path_to_pdbqt=${path_to_iteration}/pdbqt
path_to_docked=${path_to_iteration}/docked

# For each set (test/train/valid) directory, create a matching directory in docked (output) directory and run batches within 
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
        sbatch --account $account_name --partition $partition scripts_3/run_batch_docking.sh ${trimmed_batch} $receptor $configuration_file ${path_to_docked}/${directory_set_name} $vina_path "$use_vina_gpu"
    done
done
