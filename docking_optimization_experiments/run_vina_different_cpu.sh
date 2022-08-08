#!/bin/bash
#SBATCH --account VENDRUSCOLO-SL3-CPU
#SBATCH --partition skylake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=08:30:00

for i in {10..1}
 do
    for compound in random_compound_sample_20/*
    do
      tmp="$compound"
      full_filename="${tmp##*/}"
      zinc_id="${full_filename%.*}"
      echo $zinc_id >> output_run_vina_different_cpu/consise_log.out
      SECONDS=0
      /home/mb2462/test/DD_protocol_data/VINA/autodock_vina_1_1_2_linux_x86/bin/vina --receptor receptor.pdbqt --config conf.txt --cpu $i --exhaustiveness 20 --ligand $compound --out output_run_vina_different_cpu/${zinc_id}_out.pdbqt >> output_run_vina_different_cpu/consise_log.out
      duration=$SECONDS
      echo "@@@@" >> output_run_vina_different_cpu/consise_log.out
      echo "${zinc_id},${i},${duration}"
      echo "${zinc_id},${i},${duration}" >> output_run_vina_different_cpu/vina_times.txt
    done	
 done
