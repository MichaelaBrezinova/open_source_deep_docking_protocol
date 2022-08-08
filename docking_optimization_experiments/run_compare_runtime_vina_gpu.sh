#!/bin/bash
#SBATCH --account VENDRUSCOLO-SL3-GPU
#SBATCH --partition ampere
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00

ulimit -s 8192

filepath=$PWD
mkdir -p output_run_compare_runtime_vina_gpu

cd /home/mb2462/rds/hpc-work/DD/DD_protocol_data/VINA_GPU/Vina-GPU/

for compound in $filepath/random_compound_sample_100/*
    do
      echo $compound
      tmp="$compound"
      full_filename="${tmp##*/}"
      zinc_id="${full_filename%.*}"
      echo $zinc_id >> $filepath/output_run_compare_runtime_vina_gpu/consise_log.out
      SECONDS=0
      ./Vina-GPU --config $filepath/conf.txt --receptor $filepath/receptor.pdbqt --thread 8000 --search_depth 10 --ligand $compound >> $filepath/output_run_compare_runtime_vina_gpu/consise_log.out
      duration=$SECONDS
      echo "@@@@" >> $filepath/output_run_compare_runtime_vina_gpu/consise_log.out
      echo "${zinc_id},${duration}"
      echo "${zinc_id},${duration}" >> $filepath/output_run_compare_runtime_vina_gpu/vina_times.txt
    done