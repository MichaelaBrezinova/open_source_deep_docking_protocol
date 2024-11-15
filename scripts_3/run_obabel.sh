#!/bin/bash

# # Uncomment if need this modules (probably relevant only for CSD3 users)
# module load gcc
# module load boost-1.66.0-gcc-5.4.0-sdffwvs
# # modify this based on user's specific path. This is an example
# export BABEL_LIBDIR=/home/mb2462/test/DD_protocol_data/OPENBABEL/build/lib

directory_to_process=$1
obabel_path=$2

# Go to directory with the current iteration
cd $directory_to_process

# Convert each file in the directory
for f in *.sdf 
do

    # 2D-Adjustment: do not run this for the SDFs that should not be used
    if [[ $f != *_unused.sdf ]]; then
        tmp="$f"
        full_filename="${tmp##*/}"
        filename="${full_filename%.*}"

        # Run obabel to convert to right format for docking
        $obabel_path -isdf "$f" -opdbqt -O "${filename}.pdbqt" -p 7.4

        # Comment if you want to keep the original SDF file after converting to pdbqt
        rm "$f"
    fi

    # # 2D-Adjustment: original
    # tmp="$f"
    # full_filename="${tmp##*/}"
    # filename="${full_filename%.*}"
    # $obabel_path -isdf $f -opdbqt -O ${filename}.pdbqt
    # rm $f

done