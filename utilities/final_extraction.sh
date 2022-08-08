#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --account=VENDRUSCOLO-SL3-CPU
#SBATCH --partition skylake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=extract
#SBATCH --time=02:00:00 

source ~/.bashrc
conda activate $5

start=`date +%s`

if [ $4 = 'all_mol' ]; then
   echo "Extracting all SMILES"
   python utilities/final_extraction.py -smile_dir $1 -prediction_dir $2 -processors $3
else
   python utilities/final_extraction.py -smile_dir $1 -prediction_dir $2 -processors $3 -mols_to_dock $4
fi

end=`date +%s`
runtime=$((end-start))
echo $runtime
