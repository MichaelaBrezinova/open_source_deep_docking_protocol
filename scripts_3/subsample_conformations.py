import os
from argparse import ArgumentParser
import glob
import numpy as np
import shutil

# Parse the arguments
parser = ArgumentParser()
parser.add_argument("-directory_prefix", required=True,
                    help="Prefix to directory(ies) which to process")
parser.add_argument("-root_directory", required=True,
                    help="Root directory to files")
parser.add_argument('-desired_size',required=True,help='Desired set size')

io_args = parser.parse_args()
directory_prefix = io_args.directory_prefix
root_directory = io_args.root_directory
desired_size = int(io_args.desired_size)

# Create a list to store the file paths
file_paths = []

# Iterate through immediate subdirectories under the root directory
for subdir in os.listdir(root_directory):
    subdir_path = os.path.join(root_directory, subdir)
    # Check if it's a directory and its name ends with the desired prefix
    if os.path.isdir(subdir_path) and subdir.startswith(directory_prefix):
        # Get files from subdirectories of the directory
        files_in_subdir = glob.glob(os.path.join(subdir_path, "*/*.sdf"))
        file_paths.extend(files_in_subdir)

# # Now, file_paths contains the paths to all files with the specified prefix in the matching immediate subdirectories
# for file_path in file_paths:
#     print(file_path)

to_not_use_size = len(file_paths) - desired_size

# Randomly sample n file paths
seed = np.random.randint(0, 2**32)
np.random.seed(seed=seed)
# Randomly sample n file paths
sampled_paths = np.random.choice(file_paths, to_not_use_size, replace=False)

# Rename files with *.sdf extension to *_unused.sdf
for path in sampled_paths:
    base_path, ext = os.path.splitext(path)
    if ext == ".sdf":
        new_path = f"{base_path}_unused{ext}"
        try:
            shutil.move(path, new_path)
            print(f"Renamed '{path}' to '{new_path}'")
        except FileNotFoundError:
            print(f"File '{path}' not found.")

