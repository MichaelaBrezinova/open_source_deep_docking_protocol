#!/bin/bash

set_file=$1
pdbqt_directory=$2
obabel_path=$3

set_type="${set_file%_*}" # test/training/validation

echo "Set type is $set_type"

# loop through all lines in file
echo "Creating file with links"
cat $set_file | while read line || [[ -n $line ]]
do
   echo "https://zinc20.docking.org/substances/${line}.sdf";
done > "links_$set_file";

# create directory where to save downloaded SDFs
mkdir -p $sdf_directory/${set_type}

# download SDFs
echo "Downloading SDFs from links"
wget -P $pdbqt_directory/${set_type} -i links_$set_file

# # convert SDFs to corresponding obabel representation
# cd $pdbqt_directory/${set_type}
# for f in *; do
#    tmp="$f"
#    zinc_id="${tmp%.*}"
#    $obabel_path -i sdf $f -o pdbqt -O ${zinc_id}.pdbqt
# done

# # remove sdfs 
# rm *.sdf

# # split downloaded SDF to subfolders so they can be processed in parallel
# i=0; for f in *; do d=dir_$(printf %03d $((i/2500+1))); mkdir -p $d; mv "$f" $d; let i++; done
# cd ../..