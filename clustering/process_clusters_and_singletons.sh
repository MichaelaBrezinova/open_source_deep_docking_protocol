#!/bin/bash

# PROCESS SINGLETONS AND PREPARE THEIR IDS INTO A SEPARATE FILE

sed '5q;d' extracted_smiles_clusters_1024_full.txt > extracted_smiles_clusters_1024_singletons.txt
while IFS=" " read -r -a line; do printf "%s\n" "${line[@]}"; done < extracted_smiles_clusters_1024_singletons.txt > extracted_smiles_clusters_1024_singletons_clean_with_header.txt
tail -n +2 extracted_smiles_clusters_1024_singletons_clean_with_header.txt  > extracted_smiles_clusters_1024_singletons_clean.txt
rm extracted_smiles_clusters_1024_singletons_clean_with_header.txt
rm extracted_smiles_clusters_1024_singletons.txt
mv extracted_smiles_clusters_1024_singletons_clean.txt extracted_smiles_clusters_1024_singletons.txt

# SEPARATE MOLECULES TO ONES THAT ARE ISOMER AND THE ONES THAT ARE NOT
mkdir clustering_results/clusters_and_singletons
grep -v "_" clustering_results/extracted_smiles_clusters_1024.txt > clustering_results/clusters_and_singletons/clusters-no-isomers.txt
grep -v "_" clustering_results/extracted_smiles_clusters_1024_singletons.txt > clustering_results/clusters_and_singletons/singletons-no-isomers.txt

grep "_" clustering_results/extracted_smiles_clusters_1024.txt > clustering_results/clusters_and_singletons/clusters-isomers_ids.txt
grep "_" clustering_results/extracted_smiles_clusters_1024_singletons.txt > clustering_results/clusters_and_singletons/singletons-isomers_ids.txt

grep -f clustering_results/clusters_and_singletons/clusters-isomers_ids.txt extracted_smiles.smi > clustering_results/clusters_and_singletons/clusters-isomers.smi
grep -f clustering_results/clusters_and_singletons/singletons-isomers_ids.txt extracted_smiles.smi > clustering_results/clusters_and_singletons/singletons-isomers.smi
