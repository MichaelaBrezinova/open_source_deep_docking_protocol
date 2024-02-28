#!/bin/bash

# Uncomment if need this modules (probably relevant only for CSD3 users)
module load gcc
module load boost-1.66.0-gcc-5.4.0-sdffwvs
export BABEL_LIBDIR=/home/mb2462/test/DD_protocol_data/OPENBABEL/build/lib

directory_to_process=$1
obabel_path=$2
openeye_path=$3
openeye_license_path=$4

# Go to directory with the current iteration
cd $directory_to_process

# Copy in OpenEye license to the directory. This is required for OpenEye's tautomer
# to run properly
cp $openeye_license_path .

# Convert each file in the directory
for f in *.sdf 
do

    # 2D-Adjustment: do not run this for the SDFs that should not be used
    if [[ $f != *_unused.sdf ]]; then
        tmp="$f"
        full_filename="${tmp##*/}"
        filename="${full_filename%.*}"

        # Run tautomers to correct for wrong pH-representations
        ${openeye_path}/bin/tautomers -in "$f" -out "${filename}_corrected.sdf" -maxtoreturn 1 -warts false

        # Run obabel to convert to right format for docking
        $obabel_path -isdf "${filename}_corrected.sdf" -opdbqt -O "${filename}.pdbqt"
        
        # # Comment if you want to keep the original SDF file and corrected SDF file after converting to pdbqt
        # rm "$f"
        # rm "${filename}_corrected.sdf"
    fi

    # # 2D-Adjustment: without adjustment
    # tmp="$f"
    # full_filename="${tmp##*/}"
    # filename="${full_filename%.*}"

    # # Run tautomers to correct for wrong pH-representations
    # ${openeye_path}/bin/tautomers -in "$f" -out "${filename}_corrected.sdf" -maxtoreturn 1 -warts false
    
    # # Run obabel to convert to right format for docking
    # $obabel_path -isdf $f -opdbqt -O ${filename}.pdbqt
    # rm $f

done

# Remove OpenEye license from this folder
openeye_license_tmp="$openeye_license_path"
openeye_license_full_filename="${openeye_license_tmp##*/}"
echo $openeye_license_full_filename
rm $openeye_license_full_filename