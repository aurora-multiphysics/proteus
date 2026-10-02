#!/bin/bash

# This script installs Proteus on Fedora,
# including a MOOSE framework build in the $HOME directory.
# Optimised to the native system architecture.
# A .proteus_profile script is added to the $HOME directory.
# This script is intended to be used from the proteus directory
#   ./scripts/install_fedora.sh
# Use the installation by typing:
#   source $HOME/.proteus_profile

PROTEUS_DIR=$(pwd)
export PROTEUS_DIR

# If MOOSE_JOBS is unset, set to 1
if [ -z "$MOOSE_JOBS" ]; then
    export MOOSE_JOBS=1
fi
export METHODS="opt"

# Make Proteus profile

echo "export CC=mpicc
export CXX=mpicxx
export F90=mpif90
export F77=mpif77
export FC=mpif90
export MOOSE_DIR=$HOME/moose
export PATH=\$PATH:$PROTEUS_DIR" > "$HOME/.proteus_profile"
# shellcheck source=/dev/null
source "$HOME/.proteus_profile"

# Clone MOOSE from git

cd "$HOME" || exit
git clone https://github.com/idaholab/moose.git

# Build PETSc

cd "$MOOSE_DIR" || exit
unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh \
    --CXXOPTFLAGS="-O3 -march=native" \
    --COPTFLAGS="-O3 -march=native" \
    --FOPTFLAGS="-O3 -march=native" 2>&1 | tee "$PROTEUS_DIR/log.petsc_build"

# Build libMesh

./scripts/update_and_rebuild_libmesh.sh --with-mpi 2>&1 | tee "$PROTEUS_DIR/log.libmesh_build"

# Build WASP

./scripts/update_and_rebuild_wasp.sh 2>&1 | tee "$PROTEUS_DIR/log.wasp_build"

# Configure AD
# Derivative size should be the total of
# 8 for each first order variable
# 27 for each second order variable

./configure --with-derivative-size=89 2>&1 | tee "$PROTEUS_DIR/log.moose_configure"

cd "$PROTEUS_DIR" || exit
make -j "$MOOSE_JOBS" 2>&1 | tee "$PROTEUS_DIR/log.proteus_build"

echo "Installation complete."
