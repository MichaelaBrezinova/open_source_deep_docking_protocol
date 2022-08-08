#!/bin/bash
#SBATCH --account VENDRUSCOLO-SL3-CPU
#SBATCH --partition skylake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --time=02:00:00

mkdir -p output_run_compare_runtime_vina

for compound in random_compound_sample_100/*
    do
      tmp="$compound"
      full_filename="${tmp##*/}"
      zinc_id="${full_filename%.*}"
      echo $zinc_id >> output_run_compare_runtime_vina/consise_log.out
      SECONDS=0
      /home/mb2462/test/DD_protocol_data/VINA/autodock_vina_1_1_2_linux_x86/bin/vina --receptor receptor.pdbqt --config conf.txt --cpu 5 --exhaustiveness 20 --ligand $compound --out output_run_compare_runtime_vina/${zinc_id}_out.pdbqt >> output_run_compare_runtime_vina/consise_log.out
      duration=$SECONDS
      echo "@@@@" >> output_run_compare_runtime_vina/consise_log.out
      echo "${zinc_id},${duration}"
      echo "${zinc_id},${duration}" >> output_run_compare_runtime_vina/vina_times.txt
    done
