#!/bin/bash

# This script installs Proteus on CSD3,
# including a MOOSE framework build in the $HOME directory.
# Optimised to the native system architecture on the cclake partition.
# A .proteus_profile script is added to the $HOME directory.
# This script is intended to be used from the proteus directory
#   ./scripts/install_csd3.sh
# Use the installation by typing:
#   source $HOME/.proteus_profile

export PROTEUS_DIR=`pwd`

# Make Proteus profile

echo "module purge" > $HOME/.proteus_profile
echo "module load dot slurm rhel7/global" >> $HOME/.proteus_profile
echo "module load git-2.31.0-gcc-5.4.0-ec3ji34 python/3.8 gcc/9 openmpi/gcc/9.3/4.0.4" >> $HOME/.proteus_profile
echo "export CC=mpicc" >> $HOME/.proteus_profile
echo "export CXX=mpicxx" >> $HOME/.proteus_profile
echo "export F90=mpif90" >> $HOME/.proteus_profile
echo "export F77=mpif77" >> $HOME/.proteus_profile
echo "export FC=mpif90" >> $HOME/.proteus_profile
echo "export MOOSE_DIR="$HOME"/moose" >> $HOME/.proteus_profile
echo "export PATH=\$PATH:"$PROTEUS_DIR >> $HOME/.proteus_profile
echo "export PATH=\$MOOSE_DIR/petsc/arch-moose/bin/:\$PATH" >> $HOME/.proteus_profile
echo "export OMPI_MCA_mca_base_component_show_load_errors=0" >> $HOME/.proteus_profile
source $HOME/.proteus_profile

# Clone MOOSE from git

cd $HOME
git clone --depth=1 https://github.com/idaholab/moose.git

# Set MOOSE jobs to 4 (max allowed on login node)
export MOOSE_JOBS=4

# Build PETSc

cd $MOOSE_DIR
unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh \
CC=$CC CXX=$CXX F90=$F90 F77=$F77 FC=$FC \
--CXXOPTFLAGS="-O3 -march=cascadelake -mtune=cascadelake" \
--COPTFLAGS="-O3 -march=cascadelake -mtune=cascadelake" \
--FOPTFLAGS="-O3 -march=cascadelake -mtune=cascadelake" \
--download-mumps=0 --download-superlu_dist=0 --with-64-bit-indices=1 \
--download-cmake

# Build libMesh

METHODS="opt" ./scripts/update_and_rebuild_libmesh.sh --with-mpi

# Build WASP

./scripts/update_and_rebuild_wasp.sh

# Configure AD
# Derivative size should be the total of
# 8 for each first order variable
# 27 for each second order variable

./configure --with-derivative-size=89

cd $PROTEUS_DIR
make -j $MOOSE_JOBS

echo "Installation complete."
