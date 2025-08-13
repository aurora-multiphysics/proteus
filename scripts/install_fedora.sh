#!/bin/bash

# This script installs Proteus on Fedora,
# including a MOOSE framework build in the $HOME directory.
# Optimised to the native system architecture.
# A .proteus_profile script is added to the $HOME directory.
# This script is intended to be used from the proteus directory
#   ./scripts/install_fedora.sh
# Use the installation by typing:
#   source $HOME/.proteus_profile

export PROTEUS_DIR=`pwd`

# If MOOSE_JOBS is unset, set to 1
if [ -z $MOOSE_JOBS ]; then
  export MOOSE_JOBS=1
fi
export METHODS="opt"

# Make Proteus profile

echo "export CC=mpicc" > $HOME/.proteus_profile
echo "export CXX=mpicxx" >> $HOME/.proteus_profile
echo "export F90=mpif90" >> $HOME/.proteus_profile
echo "export F77=mpif77" >> $HOME/.proteus_profile
echo "export FC=mpif90" >> $HOME/.proteus_profile
echo "export MOOSE_DIR="$HOME"/moose" >> $HOME/.proteus_profile
echo "export PATH=\$PATH:"$PROTEUS_DIR >> $HOME/.proteus_profile
source $HOME/.proteus_profile

# Clone MOOSE from git

cd $HOME
git clone https://github.com/idaholab/moose.git

# Build PETSc

cd $MOOSE_DIR
git submodule update --init --recursive petsc
cd petsc
git checkout 95934b0d3930a39ae37491dd05d108b6eb525436
git fetch
git cherry-pick f2f920b56d7fa89d9d8b983964ab906256c400d9
git cherry-pick d2d2d1ac090ea262ad2aa7184201b8dfcef2e718
git cherry-pick 6cde835db1a70eda20dd10f907d8f17e178de56a
git cherry-pick 45dc274169a9b1757f9ad531048926c0ae150c8c
git cherry-pick 008f48a8bb105f7eabcdd8fe2609412f5c6c1729
cd ..
unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh \
--skip-submodule-update \
--CXXOPTFLAGS="-O3 -march=native" \
--COPTFLAGS="-O3 -march=native" \
--FOPTFLAGS="-O3 -march=native" | tee $PROTEUS_DIR/log.petsc_build

# Build libMesh

./scripts/update_and_rebuild_libmesh.sh --with-mpi | tee $PROTEUS_DIR/log.libmesh_build

# Build WASP

./scripts/update_and_rebuild_wasp.sh | tee $PROTEUS_DIR/log.wasp_build

# Configure AD
# Derivative size should be the total of
# 8 for each first order variable
# 27 for each second order variable

./configure --with-derivative-size=89 | tee $PROTEUS_DIR/log.moose_configure

cd $PROTEUS_DIR
make -j $MOOSE_JOBS | tee $PROTEUS_DIR/log.proteus_build

echo "Installation complete."
