#!/bin/bash

# $1 - test/training/validation set file
# $2 - directory where sdf files should be stored

tmp = "hello_world"
set_type = "${tmp%_*}" # test/training/validation

echo "Set type is $set_type"

# loop through all lines in file
echo "Creating file with links"
cat $1 | while read line || [[ -n $line ]]
do
   echo "https://zinc20.docking.org/substances/${line}.sdf";
done > "links_$1";

# create directory where to save downloaded SDFs
specific_set_directory = "$2/{$set_type}_set_sdf"
mkdir -p $specific_set_directory

# download SDFs
echo "Downloading SDFs from links"
wget -P $specific_set_directory -i links_$1