# The Open-source deep docking protocol and downstream analysis

This **open-source deep docking pipeline** is built upon an original Deep Docking pipeline created by Gentile et al. ([original protocol](https://www.nature.com/articles/s41596-021-00659-2)).

## Instructions
To see detailed instructions on how to run the protocol, please refer to the **Open-Source Deep Docking.ipynb** notebook provided in this repository. The optional downstream analysis is described in **clustering_and_downstream_analysis/Clustering_and_downstream_analysis.ipynb**. The instructions are adjusted to use on CSD3 cluster provided by the University of Cambridge, however, can be easily changed to work on any platform. 

### TL;DR

#### Hardware
The pipeline was run on a high-performance computing server of the University of Cambridge (CSD3), however, it can be easily run on any server with sufficient resources. This server provides $\geq$ 1 TB of allocated space and **access to CPU cores** as well as NVIDIA A100-SXM-80GB **GPU cores**. Hardware requirements for the pipeline are detailed more in the [original protocol](https://www.nature.com/articles/s41596-021-00659-2). However, the full library of SMILES and Morgan fingerprints has a size of around **267GB**, hence this amount of disk space is recommended, along with additional space for intermediate files and results. 

#### Dependencies

The protocol was originally run on server nodes using **RHEL 7/8** operating system and SLURM.

**DD_protocol.yml** (main), **DD_protocol_tensor.yml** (for model training, with different version of tensorflow required by A100 GPU units, can be combined with DD_protocol environment or omitted if not needed) and **DD_protocol_py27.yml** (for use of ChemFp 1.x) contain exported environments with dependencies that were used during the run of the pipeline and are referenced in aforementioned jupyter notebooks. 

The main dependencies are similar to those of the [original protocol](https://www.nature.com/articles/s41596-021-00659-2), 
* *rdkit*
* *tensorflow* >= 1.14.0 (1.15 GPU version recommended. If you are using cuda11, please use [nvidia-tensorflow](https://developer.nvidia.com/blog/accelerating-tensorflow-on-a100-gpus/))
* *pandas*
* *numpy*
* *keras*
* *matplotlib*
* *scikit-learn*

Protocol uses [AutoDock Vina](https://vina.scripps.edu/)/[Vina-GPU](https://github.com/DeltaGroupNJUPT/Vina-GPU) and [Open Babel](https://github.com/openbabel/openbabel).

For downstream analysis, [chemfp 1.x](https://chemfp.com/), [gaucamol](https://github.com/BenevolentAI/guacamol)  are required as well as installation and use of [DeePred-BBB](https://github.com/12rajnish/DeePred-BBB), [FRED](https://docs.eyesopen.com/applications/oedocking/fred/fred.html#chapter-fred). Chemfp 1.x supports only Python 2.7, hence to use it, an environment with Python 2.7 has to be used (e.g. DD_protocol_py27.yml). These are, however, optional if user wants to omit or adjust these steps. 

The installation times for all these tools are standard ( <5 mins).

#### Data

DD-prepared version (provided with the [original protocol](https://www.nature.com/articles/s41596-021-00659-2)) of the ZINC20 library (as available in March 2021) is available at https://files.docking.org/zinc20-ML/.

#### Example
An example target receptor (receptor.pdbqt) with configuration file (conf.txt) required by Vina and parameter file (logs.txt) are available in **results** directory (TODO). **Open-Source Deep Docking.ipynb** contains workflow using this example. Example output after one iteration for DD-prepared library (filtered by molecular weight <=360) is available at XXX(TODO). 

The duration of full run (in our case it was 5 iterations, possible to change) depends on available hardware and cluster waiting times and number of molecules docked in each iteration. However, on average it should take around 1-2 weeks (in human terms, not computer time). 

## Citation
To cite the original papers by Gentile et al., please use:

```bibtex
@article{gentile2020deep,
  title={Deep docking: a deep learning platform for augmentation of structure based drug discovery},
  author={Gentile, Francesco and Agrawal, Vibudh and Hsing, Michael and Ton, Anh-Tien and Ban, Fuqiang and Norinder, Ulf and Gleave, Martin E and Cherkasov, Artem},
  journal={ACS central science},
  volume={6},
  number={6},
  pages={939--949},
  year={2020},
  publisher={ACS Publications}
}

@article{gentile2022artificial,
  title={Artificial intelligence--enabled virtual screening of ultra-large chemical libraries with deep docking},
  author={Gentile, Francesco and Yaacoub, Jean Charle and Gleave, James and Fernandez, Michael and Ton, Anh-Tien and Ban, Fuqiang and Stern, Abraham and Cherkasov, Artem},
  journal={Nature Protocols},
  volume={17},
  number={3},
  pages={672--697},
  year={2022},
  publisher={Nature Publishing Group UK London}
}
