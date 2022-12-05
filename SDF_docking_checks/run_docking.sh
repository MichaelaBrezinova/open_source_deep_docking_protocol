#!/bin/bash

#SBATCH --account VENDRUSCOLO-SL3-GPU
#SBATCH --partition ampere
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00

vina_gpu=/home/mb2462/rds/hpc-work/DD/DD_protocol_data/VINA_GPU/Vina-GPU

ulimit -s 8192

cd $vina_gpu

./Vina-GPU --receptor /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/receptor.pdbqt  --config /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/conf.txt --thread 8000 --search_depth 10 --ligand /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main_clean/SDF_docking_checks/ZINC000002443590_1.pdbqt 

./Vina-GPU --receptor /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/receptor.pdbqt  --config /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/conf.txt --thread 8000 --search_depth 10 --ligand /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main_clean/SDF_docking_checks/ZINC000002443590_2.pdbqt 

./Vina-GPU --receptor /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/receptor.pdbqt  --config /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/conf.txt --thread 8000 --search_depth 10 --ligand /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main_clean/SDF_docking_checks/ZINC000002443590.pdbqt 
