#!/bin/bash
#SBATCH --cpus-per-task=3
#SBATCH --account=VENDRUSCOLO-SL3-GPU
#SBATCH --partition ampere
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --job-name=phase_4

# EXAMPLE INPUT: 
# sbatch phase_4_vina.sh 1 3 results abeta ampere 11 1 0.01 0.9 00-12:00 DD_protocol VENDRUSCOLO-SL3-GPU

# PARAMETERS
current_iteration=$1
t_pos=$2    # total number of processers available
path_project=$3
project_name=$4
partition=$5
desired_number_of_iterations=$6
percent_first_mols_hits=$7
percent_last_mols_hits=$8
recall=$9
time=${10}
env=${11}
account_name=${12}

source ~/.bashrc
conda activate $env

# Get relevant parameters from logs.txt file
file_path=`sed -n '1p' $3/$4/logs.txt`
protein=`sed -n '2p' $3/$4/logs.txt`

morgan_directory=`sed -n '4p' $3/$4/logs.txt`
smile_directory=`sed -n '5p' $3/$4/logs.txt`
nhp=`sed -n '7p' $3/$4/logs.txt`    # number of hyperparameters
sof=`sed -n '6p' $3/$4/logs.txt`    # The docking software used
num_molec=`sed -n '8p' $3/$4/logs.txt` # Number of molecules in testing/validation set

# echo "writing jobs"
# python jobid_writer.py -pt $protein -fp $file_path -n_it $current_iteration -jid $SLURM_JOB_NAME -jn $SLURM_JOB_NAME.txt

# Check if this iteration is the last
if [ ${desired_number_of_iterations} = ${current_iteration} ]; then
   last='True'
else
   last='False'
fi

# Create jobs that will be later run independently
echo "Creating simple jobs"
python scripts_2/simple_job_models.py -n_it $current_iteration -mdd $morgan_directory -time $time -file_path $file_path/$protein -nhp $nhp -titr $desired_number_of_iterations -n_mol $num_molec -pfm $percent_first_mols_hits -plm $percent_last_mols_hits -ct $recall -gp $partition -tf_e $env -isl $last

# If changing directories fails, stop the process
cd $file_path/$protein/iteration_${current_iteration} || { echo 'Trouble changing directories' ; exit 1; }
rm model_no.txt
cd simple_job || { echo 'There are no simple jobs ready to execute' ; exit 1; }

echo "Running simple jobs"
#Executes all the files that were created in the simple_jobs directory
for f in simple_job_*.sh;do sbatch --account $account_name --partition $partition $f;done
