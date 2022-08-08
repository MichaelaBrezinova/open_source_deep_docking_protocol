#!/bin/bash

directory_to_process=$1
obabel_path=$2
# Go to directory with the current iteration
cd $directory_to_process

# Convert each file in the directory
for f in *.sdf 
do
    tmp="$f"
    full_filename="${tmp##*/}"
    filename="${full_filename%.*}"
    $obabel_path -isdf $f -opdbqt -O ${filename}.pdbqt
done