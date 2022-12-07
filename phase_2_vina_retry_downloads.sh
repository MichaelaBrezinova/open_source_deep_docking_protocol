#!/bin/bash

#SBATCH --account VENDRUSCOLO-SL3-CPU
#SBATCH --partition skylake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=10:00:00

current_iteration=$1
path_project=$2
project_name=$3

# Get paths
file_path=`sed -n '1p' $path_project/$project_name/logs.txt`
protein=`sed -n '2p' $path_project/$project_name/logs.txt`

# Go to directory with the current iteration
cd $file_path/$protein/iteration_${current_iteration}

pdbqt_directory="pdbqt"

# For each batch file that has not been downloaded due to request failure, run the download again.
echo "retry based on number of lines"
for d in ${pdbqt_directory}/*_download;
do
tmp="$d"
directory_set_name_full="${tmp##*/}"
set_type="${directory_set_name_full%_*}" # train/test/validation
echo $set_type
   for f in $d/*.sdf
   do
       x=$(wc -l < "$f")
       if [ $x -lt 1000 ];
       then
           tmp="$f"
           full_filename="${tmp##*/}"
           filename="${full_filename%.*}"
           script_name=${set_type}_set_scripts/download_${filename}.sh
           echo "Retrying script ${script_name}"
        #    chmod u+x $script_name
        #    ./$script_name
       fi
   done
done

# For each batch file that has less compounds downloaded than 1000, repeat the download
echo "retry based on number of compounds"
for d in ${pdbqt_directory}/*_download;
do
tmp="$d"
directory_set_name_full="${tmp##*/}"
set_type="${directory_set_name_full%_*}" # train/test/validation
echo $set_type
   for f in $d/*.sdf
   do
       x=$(grep -wc "\$\$\$\$" < "$f")
       if [ $x -lt 1000 ];
       then
           tmp="$f"
           full_filename="${tmp##*/}"
           filename="${full_filename%.*}"
           script_name=${set_type}_set_scripts/download_${filename}.sh
           echo "Retrying script ${script_name}"
        #    chmod u+x $script_name
        #    ./$script_name
       fi
   done
done
