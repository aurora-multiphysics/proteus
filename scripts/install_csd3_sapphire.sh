#!/bin/bash

# This script installs Proteus on CSD3,
# including a MOOSE framework build in the $HOME directory.
# Optimised to the native system architecture on the sapphire partition.
# A .proteus_profile script is added to the $HOME directory.
# This script is intended to be used from the proteus directory
#   ./scripts/install_csd3_sapphire.sh
# Use the installation by typing:
#   source $HOME/.proteus_profile

export PROTEUS_DIR=$(pwd)

# Make Proteus profile

echo "module purge" > $HOME/.proteus_profile
echo "module load rhel8/default-sar python/3.11.0-icl" >> $HOME/.proteus_profile
echo "export CC=mpicc" >> $HOME/.proteus_profile
echo "export CXX=mpicxx" >> $HOME/.proteus_profile
echo "export F90=mpif90" >> $HOME/.proteus_profile
echo "export F77=mpif77" >> $HOME/.proteus_profile
echo "export FC=mpif90" >> $HOME/.proteus_profile
echo "export MOOSE_DIR="$HOME"/moose" >> $HOME/.proteus_profile
echo "export PATH=\$PATH:"$PROTEUS_DIR >> $HOME/.proteus_profile
echo "unset I_MPI_PMI_LIBRARY" >> $HOME/.proteus_profile
source $HOME/.proteus_profile

# Clone MOOSE from git

cd $HOME
git clone --depth=1 https://github.com/idaholab/moose.git

# Set MOOSE jobs to 4 (max allowed on login node)
export MOOSE_JOBS=4 METHODS="opt"

# Build PETSc

cd $MOOSE_DIR
unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh --download-cmake

# Build libMesh

./scripts/update_and_rebuild_libmesh.sh --with-mpi --disable-netgen

# Build WASP

./scripts/update_and_rebuild_wasp.sh

# Configure AD
# Derivative size should be the total of
# 8 for each first order variable
# 27 for each second order variable

./configure --with-derivative-size=89

# Apply patch for Intel compilers

git apply $PROTEUS_DIR/scripts/intel.patch

cd $PROTEUS_DIR
make -j $MOOSE_JOBS

echo "Installation complete."
