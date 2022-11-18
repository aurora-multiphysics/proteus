#Docker file to be built within the Proteus main directory

# Get latest base MOOSE image
FROM idaholab/moose:latest

#Set author of the image
#MAINTAINER "Alexander Whittle"

# By default 2 cores are used to compile
ARG compile_cores=2

#Install dependencies
RUN apt-get update && apt-get install -y\
    gcc \
    g++ \
#    gcc-c++ \
#    gcc-fortran \
    gfortran \ 
    cmake \
    bison \
    flex \
    git \
    python3 \
    python3-dev \
    python-is-python3 \
    python3-packaging \
#    python3-devel \
    openmpi-bin \
#    openmpi-devel \
    libopenmpi-dev \
    libboost-filesystem-dev 
#    libtirpc-devel \
#    zlib-devel \
#    perl-File-Compare 

#Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    make -j"$compile_cores"

#Run tests

