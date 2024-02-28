#!/bin/bash

directory_to_process=$1
openeye_path=$2
openeye_license_path=$3

# Go to directory with the current iteration
cd $directory_to_process

# Copy in OpenEye license to the directory. This is required for OpenEye's tautomer
# to run properly
cp $openeye_license_path .

# # Uncomment in case you want to measure duration of this process
# start_time=$(date +%s)

# Convert each file in the directory
for f in *.sdf 
do

    # 2D-Adjustment: do not run this for the SDFs that should not be used
    if [[ $f != *_unused.sdf ]]; then
        tmp="$f"
        full_filename="${tmp##*/}"
        filename="${full_filename%.*}"

        # Run tautomers to correct for wrong pH-representations
        # ${openeye_path}/bin/tautomers -in "$f" -out "${filename}_corrected.sdf" -maxtoreturn 1 -warts false
        ${openeye_path}/bin/tautomers -in "$f" -out "${filename}_corrected.smi" -maxtoreturn 1 -warts false

        # # Comment if you do not want the original file to be removed after correcting
        # rm $f 

    fi

    # # 2D-Adjustment: without adjustment
    # tmp="$f"
    # full_filename="${tmp##*/}"
    # filename="${full_filename%.*}"
    # ${openeye_path}/bin/tautomers -in "$f" -out "${filename}_corrected.sdf" -maxtoreturn 1 -warts false
    # rm $f

done

# # Uncomment in case you want to measure duration of this process
# end_time=$(date +%s)
# duration=$((end_time - start_time))

# echo "$duration seconds" >  duration_tautomers.out

# Remove OpenEye license from this folder
openeye_license_tmp="$openeye_license_path"
openeye_license_full_filename="${openeye_license_tmp##*/}"
rm $openeye_license_full_filename