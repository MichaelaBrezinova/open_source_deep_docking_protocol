import pandas as pd
from argparse import ArgumentParser
import smilite

parser = ArgumentParser()
parser.add_argument("-file_num", type=int, default=0,
                    help="The number of file to process")
args = parser.parse_args()
print("check if its integer")
print(isinstance(args.file_num, int))
print("file no" + str(args.file_num))
for i in range(20):
    print(i)

smile =smilite.get_zinc_smile("ZINC000196558273", backend="zinc15")
print(smile)
f = open("test_print_numbers_output.txt", "a")
f.write("Creating files works!")
f.close()
