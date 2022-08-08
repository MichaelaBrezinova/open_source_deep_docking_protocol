#!/bin/bash

#SBATCH --account VENDRUSCOLO-SL3-CPU
#SBATCH --partition skylake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=01:00:00

file_name=$1
path_project=$2
project_name=$3
path_to_morgan=$4
path_to_smiles=$5

path_to_store=$path_project/$project_name/iteration_1
total_sampling=$(wc -l < "${file_name}")

echo "total sampling $total_sampling"

python scripts_1/molecular_file_count_updated.py --project_name $project_name --n_iteration 1 --data_directory $path_to_morgan --tot_process 10 --tot_sampling $total_sampling

# Filter out original dataset - filter ZINCs that are not in the library. 
# Uncomment if needed. If used, please make sure to update the file_name to the filtered set for the subsequent steps. 
# If used, please adjust the memory needed for the job.
# python scripts_3/original_dataset_processing/filter_original_dataset.py -original_dataset $file_name -directory_to_compare $path_to_smiles

mkdir -p $path_to_store

# Split dataset to 3 equally size parts
echo "splitting $file_name"
python scripts_3/original_dataset_processing/split_original_dataset.py -file_to_process $file_name -path_to_store $path_to_store

# Extract Morgan fingerprints and smiles
echo "extracting morgan and smiles"
python scripts_1/extracting_morgan.py -pt $project_name -fp $path_project -it 1 -md $4 -t_pos 10
python scripts_1/extracting_smiles.py -pt $project_name -fp $path_project -it 1 -smd $5 -t_pos 10

# Extract labels for original dataset
echo "extracting labels"
python scripts_3/original_dataset_processing/extract_labels_original_dataset.py -file_name $file_name -path_to_sets $path_to_store