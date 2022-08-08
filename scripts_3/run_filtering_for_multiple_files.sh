#!/bin/bash
directory_to_filter=$1
output_directory=$2

# If you want to use different filtering options, please change it here
for file in $directory_to_filter/*; 
do sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=10 --time=02:00:00 --wrap "python scripts_3/filter_by_properties.py -file $file -output_directory $output_directory -use_only_molWt True"
done
