#!/bin/bash
module load gcc
module load boost-1.66.0-gcc-5.4.0-sdffwvs

chunk_file=$1
directory_to_store=$2
obabel=$3
oe_license=$4
receptor=$5
openeye=$6

# isolate the chunk name 
chunk_file_short_name="${chunk_file##*/}"
chunk="${chunk_file_short_name%%.*}"

# create directory for results of docking of this specific chunk
mkdir ${directory_to_store}/${chunk} || { echo 'Creating directory failed' ; exit 1; }
mkdir ${directory_to_store}/${chunk}/out_files || { echo 'Creating directory failed' ; exit 1; }
mkdir ${directory_to_store}/${chunk}/helper || { echo 'Creating directory failed' ; exit 1; }

#change to the curretn chunk's directory
cd ${directory_to_store}/${chunk}/helper || { echo 'Changing directory failed' ; exit 1; }

# copy license as this is required for the FRED to run correctly
cp $oe_license .

# Go over molecules (1 row per molecule) in the chunk file and dock them with FRED
while read p; do
    # Get the file with the VINA output for the current molecule (last column in the row) and get the molecule's name
    file="${p##*,}"
    short_filename="${file##*/}"
    zinc_id="${short_filename%%_out*}"

    # Take the file with ligand in 5 poses from Vina docking and convert it to mol2. There will be 5 output files.
    # The ligand in the pose with the best score with be the first output one (*lig1.mol2)
    $obabel --title ${zinc_id} -i pdbqt $file -o mol2 -O ${zinc_id}_lig.mol2 -m
    $obabel --title ${zinc_id} -i pdbqt $file -o pdb -O ${zinc_id}_lig.pdb -m

    rm ${zinc_id}_lig2.*
    rm ${zinc_id}_lig3.*
    rm ${zinc_id}_lig4.*
    rm ${zinc_id}_lig5.*

    # DEPRECATED METHOD
    # # Prepare receptor using the receptor file and the ligand in the pose with a best score
    # ${openeye}/bin/receptor_setup  -protein $receptor -bound_ligand ${zinc_id}_lig1.mol2 -receptor receptor.oeb

    # # Dock the ligand in the best pose to the receptor
    # ${openeye}/bin/fred -receptor /home/mb2462/rds/hpc-work/DD/DD_protocol_data/DD_main_clean/clustering/receptor.oeb -dbase ${zinc_id}_lig1.mol2 -score_file fred_score_${zinc_id}.dat -docked_molecule_file out_files/${zinc_id}_fred_out.sdf

    # NEW METHOD
    # Join receptor with ligands pdb file
    $obabel -i pdb ${receptor} ${zinc_id}_lig1.pdb -o pdb -O receptor_joined_${zinc_id}_ligand.pdb --join

    sed 's/^\(HETATM.\{15\}\) /\1X/' receptor_joined_${zinc_id}_ligand.pdb > receptor_joined_${zinc_id}_ligand_chained.pdb
    sed -i 's/UNL/LIG/g' receptor_joined_${zinc_id}_ligand_chained.pdb

    ${openeye}/bin/spruce -in receptor_joined_${zinc_id}_ligand_chained.pdb

    ${openeye}/bin/fred -receptor *.oedu -dbase ${zinc_id}_lig1.mol2 -score_file fred_score_${zinc_id}.dat -docked_molecule_file ../out_files/${zinc_id}_fred_out.sdf

    # Put score to a commond file for the whole chunk
    sed '2q;d' fred_score_${zinc_id}.dat >> ../${chunk}_docking_results.txt

    # Remove redundant files
    rm *
    cp $oe_license .

done <${chunk_file}

cd ..