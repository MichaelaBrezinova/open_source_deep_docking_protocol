#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --account=VENDRUSCOLO-SL3-GPU
#SBATCH --partition=ampere
#SBATCH --job-name=phase_5
#SBATCH --time=01:00:00

# EXAMPLE INPUT: sbatch phase_5_vina.sh 1 results abeta 0.9 ampere DD_protocol VENDRUSCOLO-SL3-GPU

# PARAMETERS
current_iteration=$1
path_to_project=$2
project_name=$3
recall_value=$4
gpu_partition=$5 # name of gpu partition
env=${6} # conda environment name
account_name=$7

source ~/.bashrc
conda activate $env

file_path=`sed -n '1p' ${path_to_project}/${project_name}/logs.txt`
protein=`sed -n '2p' ${path_to_project}/${project_name}/logs.txt`    # name of project folder
morgan_directory=`sed -n '4p' ${path_to_project}/${project_name}/logs.txt`
num_molec=`sed -n '8p' ${path_to_project}/${project_name}/logs.txt` # number of molecules used in testing/validation set

# Full morgan path is needed for this to work correctly
current_directory="$PWD"
full_morgan_path=$current_directory/$morgan_directory

python jobid_writer.py -pt $protein -fp $file_path -n_it ${current_iteration} -jid $SLURM_JOB_NAME -jn $SLURM_JOB_NAME.txt

# Evaluate and pick the best model
echo "Starting Evaluation"
python -u scripts_2/hyperparameter_result_evaluation.py -n_it ${current_iteration} -d_path $file_path/$protein -mdd $morgan_directory -n_mol $num_molec -ct ${recall_value}

# Create jobs that will predict hits in the whole library  - one script/job per file (as we have data organized in smaller files)
echo "Creating simple_job_predictions"
python scripts_2/simple_job_predictions.py -pt $protein -fp $file_path -n_it ${current_iteration} -mdd $morgan_directory -gp $gpu_partition -tf_e $env -full_morgan_path $full_morgan_path

# Run each job independently
cd $file_path/$protein/iteration_$1/simple_job_predictions/ || { echo 'There are no simple jobs ready to execute' ; exit 1; }
echo "running simple_jobs"
for f in simple_job_*.sh;do sbatch --account $account_name $f;done
