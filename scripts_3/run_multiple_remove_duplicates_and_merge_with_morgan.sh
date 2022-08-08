#!/bin/bash
input_directory_smiles=$1
input_directory_fingerprints=$2
output_directory_smiles=$3
output_directory_fingerprints=$4

sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=10 --time=02:00:00 --wrap "python scripts_3/remove_duplicates_and_merge_with_morgan.py -start_file 0 -end_file 25 -input_directory_smiles $1 -input_directory_fingerprints $2 -output_directory_smiles $3 -output_directory_fingerprints $4"; 

sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=10 --time=02:00:00 --wrap "python scripts_3/remove_duplicates_and_merge_with_morgan.py -start_file 26 -end_file 50 -input_directory_smiles $1 -input_directory_fingerprints $2 -output_directory_smiles $3 -output_directory_fingerprints $4"; 

sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=10 --time=02:00:00 --wrap "python scripts_3/remove_duplicates_and_merge_with_morgan.py -start_file 51 -end_file 75 -input_directory_smiles $1 -input_directory_fingerprints $2 -output_directory_smiles $3 -output_directory_fingerprints $4";  

sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=10 --time=02:00:00 --wrap "python scripts_3/remove_duplicates_and_merge_with_morgan.py -start_file 76 -end_file 99 -input_directory_smiles $1 -input_directory_fingerprints $2 -output_directory_smiles $3 -output_directory_fingerprints $4"; 