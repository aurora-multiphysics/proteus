#!/bin/bash

# This script installs Proteus pre-requisites on Ubuntu,
# This script is intended to be used from the proteus directory
#   ./scripts/install_ubuntu_prerequisites.sh

# Install pre-requisites

sudo apt install -y gcc g++ gfortran cmake bison flex git
sudo apt install -y python3 python3-dev python-is-python3 python3-packaging
sudo apt install -y openmpi-bin libopenmpi-dev libboost-all-dev libtirpc-dev
