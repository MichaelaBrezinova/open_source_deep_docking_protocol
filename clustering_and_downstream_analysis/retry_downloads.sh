#!/bin/bash
shopt -s extglob

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=02:00:00

folder=$1
n_cpus_per_node=$2
name_cpu_partition=$3
account_name=$4
original_chunk_size=$5
original_chunk_pattern=$6
new_chunk_size=$7

# Go to directory with the current iteration
cd $folder

pdbqt_directory="pdbqt"

# For each batch file that has not been downloaded due to request failure, run the download again.
echo "retry based on number of lines"
for d in ${pdbqt_directory}/*_download;
do
tmp="$d"
directory_set_name_full="${tmp##*/}"
set_type="${directory_set_name_full%_*}" # train/test/validation
echo $set_type
   for f in $d/${original_chunk_pattern}
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

# For each batch file that has less compounds downloaded than $number_of_mols_to_expect, repeat the download
echo "retry based on number of compounds"
for d in ${pdbqt_directory}/*_download;
do
tmp="$d"
directory_set_name_full="${tmp##*/}"
set_type="${directory_set_name_full%_*}" # train/test/validation
echo $set_type
   for f in $d/${original_chunk_pattern}
   do
       x=$(grep -wc "\$\$\$\$" < "$f")
       if [ $x -lt ${original_chunk_size} ];
       then
           tmp="$f"
           full_filename="${tmp##*/}"
           filename="${full_filename%.*}"
           chunk_filename=${set_type}_set_scripts/${filename}.txt
           added_prefix=${filename}_
           echo "Creating subscripts for ${chunk_filename} of size ${new_chunk_size}"
        #    # Create scripts to download SDFs of chunks of size ${new_chunk_size}
       #    python /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main_clean/scripts_3/create_download_ligand_scripts.py -file ${chunk_filename} -path_to_store_scripts ${folder}/${set_type}_set_scripts -path_to_store_ligands ${folder}/${pdbqt_directory}/${set_type}_download -chunk_size ${new_chunk_size} -prefix_to_chunk_files ${added_prefix}
           rm $f
           # Run separate download job for each batch of 200
           for subfile in ${folder}/${set_type}_set_scripts/download_${added_prefix}*.sh;
            do dos2unix $subfile; echo "Retrying script ${subfile}"; sbatch -N 1 -n 1 --time=00:30:00 --cpus-per-task=$n_cpus_per_node --account=$account_name --partition=$name_cpu_partition $subfile;
           done
       fi
   done
done

# # For each batch file that has less compounds downloaded than $number_of_mols_to_expect, repeat the download
# echo "retry based on number of compounds"
# for d in ${pdbqt_directory}/*_download;
# do
# tmp="$d"
# directory_set_name_full="${tmp##*/}"
# set_type="${directory_set_name_full%_*}" # train/test/validation
# echo $set_type
#    for f in $d/*.sdf
#    do
#        x=$(grep -wc "\$\$\$\$" < "$f")
#        if [ $x -lt $number_of_mols_to_expect];
#        then
#            tmp="$f"
#            full_filename="${tmp##*/}"
#            filename="${full_filename%.*}"
#            script_name=${set_type}_set_scripts/download_${filename}.sh
#            echo "Retrying script ${script_name}"
#            chmod u+x $script_name
#            ./$script_name
#        fi
#    done
# done
