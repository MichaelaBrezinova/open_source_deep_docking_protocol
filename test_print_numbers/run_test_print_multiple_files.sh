#!/bin/bash

for i in {0..3}; 
do sbatch --account=VENDRUSCOLO-SL3-CPU --partition=skylake --nodes=1 --ntasks=1 --cpus-per-task=1 --time=00:10:00 --wrap "python test_print_numbers.py -file_num $i"; 
done
