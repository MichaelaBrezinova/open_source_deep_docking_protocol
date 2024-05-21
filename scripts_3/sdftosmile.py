#!/usr/bin/env python3

import sys
from rdkit import Chem
from argparse import ArgumentParser
from rdkit import RDLogger
lg = RDLogger.logger()
lg.setLevel(RDLogger.CRITICAL)

# Adapted from https://github.com/caiyingchun/pychem/blob/cf7e80184349993fdb1965f6f1e9bfc0e75cd1b5/sdf2smi.py

def converter(file_name, path_to_store):
    molecules = [x for x in Chem.ForwardSDMolSupplier(open(file_name,'rb')) if x is not None]
    clean_file_name = file_name.split('/')[-1].split(".")[0]
    out_file = open(path_to_store + '/' + clean_file_name + '.smi', "w")
    for mol in molecules:
        if mol is not None:             # avoiding compounds that cannot be loaded.
            smi = Chem.MolToSmiles(mol)
            zinc_id = mol.GetProp('_Name')
            out_file.write(f"{smi} {zinc_id}\n")
    out_file.close()

if __name__ == "__main__":
    # Parse the arguments
    parser = ArgumentParser()
    parser.add_argument("-file", required=True,
                        help="File to process")
    parser.add_argument("-path_to_store", default="",
                        help="Path to store the output smi file")
    args = parser.parse_args()

    converter(args.file, args.path_to_store)