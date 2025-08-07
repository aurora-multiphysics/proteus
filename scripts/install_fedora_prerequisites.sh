#!/bin/bash

# This script installs Proteus pre-requisites on Fedora,
# This script is intended to be used from the proteus directory
#   ./scripts/install_fedora_prerequisites.sh

# Install pre-requisites

sudo dnf install -y gcc gcc-g++ gcc-gfortran cmake bison flex git
sudo dnf install -y python3-devel
sudo dnf install -y openmpi openmpi-devel boost-devel libtirpc-devel
sudo dnf install -y zlib-ng-devel zlib-ng-compat-devel

echo "module load mpi" >> ~/.bashrc
