# To build the Docker container, run the following lines from your proteus root directory:
# cd docker
# docker build --rm -t proteus:latest .

# Use Ubuntu as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PROTEUS_DIR=/proteus
ENV MOOSE_DIR=/opt/moose
ENV MOOSE_JOBS=4

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
        gcc \
        g++ \
        gfortran \
        cmake \
        bison \
        flex \
        git \
        python3 \
        python3-dev \
        python-is-python3 \
        python3-packaging \
        openmpi-bin \
        libopenmpi-dev \
        libboost-all-dev \
        libtirpc-dev \
        autoconf \
        automake \
	python3-yaml	\
        libtool && \
    # Set up the Proteus profile
    echo "export CC=mpicc" > /root/.proteus_profile && \
    echo "export CXX=mpicxx" >> /root/.proteus_profile && \
    echo "export F90=mpif90" >> /root/.proteus_profile && \
    echo "export F77=mpif77" >> /root/.proteus_profile && \
    echo "export FC=mpif90" >> /root/.proteus_profile && \
    echo "export MOOSE_DIR=$MOOSE_DIR" >> /root/.proteus_profile && \
    echo "export PATH=\$PATH:$PROTEUS_DIR" >> /root/.proteus_profile && \
    . /root/.proteus_profile

# Increase git buffer size and clone MOOSE repository
RUN git config --global http.postBuffer 524288000 && \
    git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 999999 && \
    git clone --depth 1 https://github.com/idaholab/moose.git $MOOSE_DIR || \
    { echo "Retrying..."; sleep 5; git clone --depth 1 https://github.com/idaholab/moose.git $MOOSE_DIR; }

# Build PETSc
RUN cd $MOOSE_DIR && \
    unset PETSC_DIR PETSC_ARCH && \
    ./scripts/update_and_rebuild_petsc.sh \
        --CXXOPTFLAGS="-O3 -march=native" \
        --COPTFLAGS="-O3 -march=native" \
        --FOPTFLAGS="-O3 -march=native"

# Build libMesh
RUN cd $MOOSE_DIR && \
    ./scripts/update_and_rebuild_libmesh.sh --with-mpi

# Build WASP
RUN cd $MOOSE_DIR && \
    ./scripts/update_and_rebuild_wasp.sh

# Configure AD
RUN cd $MOOSE_DIR && \
    ./configure --with-derivative-size=81

# Copy Proteus source code
RUN git clone https://github.com/aurora-multiphysics/proteus.git

# Build Proteus
RUN cd $PROTEUS_DIR && \
    make -j $MOOSE_JOBS

# Set working directory
WORKDIR /proteus

# Set entrypoint
ENTRYPOINT ["/bin/bash"]

# Run tests
RUN cd /proteus && \
    ./run_tests
