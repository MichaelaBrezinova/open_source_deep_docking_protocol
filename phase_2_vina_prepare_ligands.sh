#!/bin/bash

#SBATCH --account VENDRUSCOLO-SL3-CPU
#SBATCH --partition icelake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=04:00:00

module load gcc
module load boost-1.66.0-gcc-5.4.0-sdffwvs

current_iteration=$1
path_project=$2
project_name=$3
name_cpu_partition=$4
account_name=$5
train_size=$6 # 2D-Adjustment: Add the size so we know how many molecules to keep after oversampling

# Get paths
file_path=`sed -n '1p' $path_project/$project_name/logs.txt`
protein=`sed -n '2p' $path_project/$project_name/logs.txt`
obabel_path=`sed -n '10p' $path_project/$project_name/logs.txt`
val_test_size=`sed -n '8p' $path_project/$project_name/logs.txt` # 2D-Adjustment: Add the size so we know how many molecules to keep after oversampling

# 2D-Adjustment: Adjust the desired sizes. If we are not in the first iteration, train/valid/test all represent the additional hits that will extend the original train set.
if [ "$current_iteration" -ne 1 ]; then
    val_test_size=$((train_size / 3))
    train_size=$((train_size / 3))
fi

path_to_pdbqt=$file_path/$protein/iteration_${current_iteration}/pdbqt

 #For each dataset (train/test/valid) go over the sdf files containing the chunk of ligand conformations and split them so we have
 # 1 sdf per ligand conformation. Store these single sdf files within "chunk" directory that contains all sdfs coming from the larger sdf file, so these directories can be process in parallel in next steps.
 for d in ${path_to_pdbqt}/*;
 do
 tmp="$d"
 directory_set_name="${tmp##*/}"
 echo "Processing SDFs in ${directory_set_name}"
    for f in $d/*.sdf
    do
        tmp="$f"
        full_filename="${tmp##*/}"
        filename="${full_filename%.*}"
        echo "Processing ${filename}"
        mkdir -p $d/${filename} 
        python scripts_3/split_sdfs.py -file $f -path_to_store $d/${filename}
    done
 done

# 2D-Adjustment: Subsample for train/valid/test sets. Unused ligands will be in ${path_to_pdbqt}_unused directory
python scripts_3/subsample_conformations.py -directory_prefix "train" -root_directory $path_to_pdbqt -desired_size $train_size
python scripts_3/subsample_conformations.py -directory_prefix "test" -root_directory $path_to_pdbqt -desired_size $val_test_size
python scripts_3/subsample_conformations.py -directory_prefix "valid" -root_directory $path_to_pdbqt -desired_size $val_test_size


# For all chunks within each dataset (train/test/valid), convert the single sdf files into pdbqt format (ligands chosen to not be used
# will not be converted as they are in a different folder)
for d in ${path_to_pdbqt}/*;
do
tmp="$d"
directory_set_name="${tmp##*/}"
echo "Processing SDFs in ${directory_set_name}"
   for sub_d in $d/*/
   do
       echo "Processing ${sub_d}"
       sbatch --account $account_name --partition $name_cpu_partition --nodes=1 --ntasks=1 --cpus-per-task=10 --time=00:30:00 scripts_3/run_obabel.sh $sub_d $obabel_path
   done
done
