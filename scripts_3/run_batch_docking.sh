#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1 # COMMENT OUT WHEN USING CLASSIC VINA
#SBATCH --cpus-per-task=1
#SBATCH --time=02:15:00

# PARAMETERS
batch_directory_to_dock=$1 # THIS SHOULD BE A FULL PATH IF USING VINA GPU
receptor=$2 # THIS SHOULD BE A FULL PATH IF USING VINA GPU
configuration_file=$3 # THIS SHOULD BE A FULL PATH IF USING VINA GPU
path_to_output_directory=$4 # THIS SHOULD BE A FULL PATH IF USING VINA GPU
vina_path=$5
using_vina_gpu=$6

tmp="${batch_directory_to_dock}"
batch="${tmp##*/}"

# Prepare output file paths
output_file_txt=$path_to_output_directory/docking_vina_gpu_$batch.txt
output_file_pdbqt=$path_to_output_directory/docking_vina_gpu_${batch}_dummy.pdbqt

echo $batch_directory_to_dock

# Use Vina or Vina-GPU based on the user's choice.
if [ "$using_vina_gpu" = true ] ; then
    echo "Using VINA-GPU"
    ulimit -s 8192
    # For each file in the batch directory, run VINA docking. Output of all dockings along with corresponding ZINC IDs is stored
    # to 1 file.
    cd $vina_path
    for file in $batch_directory_to_dock/*.pdbqt; do
        echo $file
        tmp="$file"
        full_filename="${tmp##*/}"
        zinc_id="${full_filename%.*}"
        echo -e "\n" >> $output_file_txt
        echo $zinc_id >> $output_file_txt
        ./Vina-GPU --receptor $receptor --config $configuration_file --thread 8000 --search_depth 10 --ligand $file >> $output_file_txt
        echo "@@@@" >> $output_file_txt
        rm ${batch_directory_to_dock}/${zinc_id}_out.pdbqt
    done
else 
    echo "Using AutoDock Vina"
    # For each file in the batch directory, run VINA docking. Output of all dockings along with corresponding ZINC IDs is stored
    # to 1 file.
    for file in $batch_directory_to_dock/*.pdbqt; do
        tmp="$file"
        full_filename="${tmp##*/}"
        zinc_id="${full_filename%.*}"
        echo -e "\n" >> $output_file_txt
        echo $zinc_id >> $output_file_txt
        $vina_path --receptor $receptor --config $configuration_file --cpu 10 --exhaustiveness 20 --ligand $file --out $output_file_pdbqt >> $output_file_txt
        echo "@@@@" >> $output_file_txt
    done;
fi
