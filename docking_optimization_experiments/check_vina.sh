#!/bin/bash
#SBATCH --account VENDRUSCOLO-SL3-GPU
#SBATCH --partition ampere
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=5
#SBATCH --time=00:10:00
SECONDS=0
/home/mb2462/test/DD_protocol_data/VINA/autodock_vina_1_1_2_linux_x86/bin/vina --receptor results/abeta/receptor.pdbqt --config results/abeta/conf.txt --cpu 5 --exhaustiveness 20 --ligand results/abeta/iteration_2/pdbqt/test/chunk_0/ZINC000000045100.pdbqt --out test_docking_directory/dummy_output.pdbqt
duration=$SECONDS
echo "Time taken ${duration}"

# for i in {1..30}
# do
#    SECONDS=0
#    /home/mb2462/test/DD_protocol_data/VINA/autodock_vina_1_1_2_linux_x86/bin/vina --receptor results/abeta/receptor.pdbqt --config results/abeta/conf.txt --cpu $i --exhaustiveness 20 --ligand results/abeta/iteration_2/pdbqt/test/chunk_0/ZINC000000045100.pdbqt --out test_docking_directory/dummy_output.pdbqt > test_docking_directory/dummy_output.txt
#    duration=$SECONDS
#    echo "${i},${duration}"
#    echo "${i},${duration}" >> test_docking_directory/vina_times.txt
# done
cd /home/mb2462/rds/hpc-work/DD/DD_protocol_data/VINA_GPU/Vina-GPU/
./Vina-GPU --config /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/conf.txt --receptor /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/receptor.pdbqt --thread 8000 --search_depth 10 --ligand /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main/results/abeta/iteration_2/pdbqt/test/chunk_0/ZINC000000045100.pdbqt
