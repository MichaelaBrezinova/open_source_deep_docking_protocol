from rdkit import Chem
from rdkit.Chem import Descriptors
from argparse import ArgumentParser
import smilite

# Parse the arguments
parser = ArgumentParser()
parser.add_argument("-file", required=True,
                    help="File to process in format SMILES <whitespace> UNIQUE_ID")
parser.add_argument("-output_directory", required=True,
                    help="Directory where to save the filtered output")
parser.add_argument("-max_logP", type=int, default=3,
                    help="The upper bound for logP(lipophilicity)")
parser.add_argument("-max_molWt", type=int, default=360,
                    help="The upper bound for molWt(molecular_weight)")
parser.add_argument("-min_TPSA", type=int, default=40,
                    help="The lower bound for TPSA(topological_polar_surface_area)")
parser.add_argument("-max_TPSA", type=int, default=90,
                    help="The upper bound for TPSA(topological_polar_surface_area)")
parser.add_argument("-max_HBD", type=int, default=0.5,
                    help="The upper bound for HBD(hydrogen_bond_donor)")
parser.add_argument("-use_only_molWt", type=bool, default=False,
                    help="If the filtering should be performed only by molWt(molecular weight)")
args = parser.parse_args()

print("Processing file " + str(args.file))

if(args.use_only_molWt):
    # FILTERING BY MOLECULAR WEIGHT
    print("Physiochemical properties filter: " + "molWt <= " + str(args.max_molWt))
else: 
    # FILTERING BY ALL PROPERTIES
    print("Physiochemical properties filter: " + "logP <= " + str(args.max_logP) + ", molWt <= " + str(args.max_molWt) 
          + ", " + str(args.min_TPSA) + " <= TPSA <= " + str(args.max_TPSA) + ', HBD <=' + str(args.max_HBD))

print("Start processing the file")
filtered_lines = []
with open(args.file) as file:
        line_counter = 0
        for line in file:
            # Display how many filtered compounds there are each 1,000,000 iterations
            if line_counter % 1000000 == 0:
                print("Currently there are " + str(len(filtered_lines)) + " compounds")
            # Get ZINC ID and smiles
            line_counter = line_counter+1
            line_split = line.split()
            zinc_smile = line_split[0]
            zinc_id = line_split[1]
            clean_zinc_id = zinc_id[0:-2]
            
            m = Chem.MolFromSmiles(zinc_smile)
            # If molecule is correct, calculate the properties and if they are within bounds, append
            # the molecule to the list
            if(m):
                if(args.use_only_molWt):
                    # FILTERING BY MOLECULAR WEIGHT
                    molWt = Descriptors.MolWt(m)
                    if(molWt <= args.max_molWt):
                        filtered_lines.append(zinc_smile + " " + zinc_id)
                else:
                    # FILTERING BY MORE PROPERTIES
                    logP = Descriptors.MolLogP(m)
                    molWt = Descriptors.MolWt(m)
                    TPSA = Descriptors.TPSA(m)
                    HBD = Chem.rdMolDescriptors.CalcNumHBD(m)
                    if(logP <= args.max_logP and molWt <= args.max_molWt 
                       and TPSA >= args.min_TPSA and TPSA <= args.max_TPSA 
                       and HBD <= args.max_HBD):
                        filtered_lines.append(zinc_smile + " " + zinc_id)
            else:
                print("Faulty SMILES encountered, trying to get smile from ZINC15")
                
                # Comment when you want to try with alternative ZNIC file
                filtered_lines.append(zinc_smile + " " + zinc_id)
                
#                 # Uncomment when you want to try with alternative ZNIC file
#                 # Try to get smile from ZINC 
#                 alternative_zinc_smile = smilite.get_zinc_smile(clean_zinc_id, backend="zinc15")
#                 if(alternative_zinc_smile):
#                     m = Chem.MolFromSmiles(alternative_zinc_smile)
#                     # If molecule is correct, calculate the properties and if they are within bounds, append
#                     # the molecule to the list
#                     if(m):
#                         if(args.use_only_molWt):
#                             # FILTERING BY MOLECULAR WEIGHT
#                             molWt = Descriptors.MolWt(m)
#                             if(molWt <= args.max_molWt):
#                                 filtered_lines.append(zinc_smile + " " + zinc_id)
#                         else:
#                             # FILTERING BY MORE PROPERTIES
#                             logP = Descriptors.MolLogP(m)
#                             molWt = Descriptors.MolWt(m)
#                             TPSA = Descriptors.TPSA(m)
#                             HBD = Chem.rdMolDescriptors.CalcNumHBD(m)
#                             if(logP <= args.max_logP and molWt <= args.max_molWt 
#                                and TPSA >= args.min_TPSA and TPSA <= args.max_TPSA 
#                                and HBD <= args.max_HBD):
#                                 filtered_lines.append(zinc_smile + " " + zinc_id)

# Write filtered lines to file
with open(args.output_directory + "/" + args.file.rsplit('/', 1)[-1], 'w') as fp:
    for line in filtered_lines:
        # write each item on a new line
        fp.write("%s\n" % line)
    print('Done writing')
