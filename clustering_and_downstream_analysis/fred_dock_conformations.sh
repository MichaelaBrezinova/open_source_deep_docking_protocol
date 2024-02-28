#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=fred_docking
#SBATCH --time=01:00:00

# You can add to SBATCH parameters defined above or provide them directly when running sbatch from terminal

file_with_selected_molecules=$1
directory_to_store=$2
obabel=$3
oe_license=$4
receptor=$5
openeye=$6
n_cpus_per_node=$7
name_cpu_partition=$8
account_name=$9

fred_directory=${directory_to_store}/fred_docked || { echo 'Creating directory failed' ; exit 1; }
mkdir $fred_directory || { echo 'Changing directory directory failed' ; exit 1; }

# Split the file containing smiles into chunks
split -l 500 --additional-suffix=.txt ${file_with_selected_molecules} ${fred_directory}/chunk_ || { echo 'Splitting file failed' ; exit 1; }

# Run the 3D conformation tool for each of the chunks in parallel
for chunk_file in ${fred_directory}/chunk_*
do
    echo "create job for fred docking of ${chunk_file}" 

    sbatch -N 1 -n 1 --time=07:30:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition ../scripts_3/run_batch_fred_docking.sh $chunk_file $fred_directory $obabel $oe_license $receptor $openeye
    
    # # Use this if you do not want to run it as a job
    # ./../scripts_3/run_batch_fred_docking.sh $chunk_file $fred_directory $obabel $oe_license $receptor $openeye
done 

