#!/bin/bash

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
        $obabel_path -isdf "$f" -opdbqt -O "${filename}.pdbqt"
        rm "$f"
    fi

    # # 2D-Adjustment: original
    # tmp="$f"
    # full_filename="${tmp##*/}"
    # filename="${full_filename%.*}"
    # $obabel_path -isdf $f -opdbqt -O ${filename}.pdbqt
    # rm $f

done