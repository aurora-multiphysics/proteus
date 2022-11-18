#Docker file to be built within the Proteus main directory
#sudo docker build --rm -t proteus:latest .

# Get latest base MOOSE image
FROM idaholab/moose:latest

#Set author of the image
#MAINTAINER "Alexander Whittle"

# By default 2 cores are used to compile
ARG compile_cores=2

#Install pre-requisites for Ubuntu
RUN apt-get update && apt-get install -y\
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
    libboost-filesystem-dev 

#Install pre-requisites for Fedora
#RUN apt-get update && apt-get install -y\
#    gcc-c++ \
#    gcc-fortran \
#    python3-devel \
#    openmpi-devel \
#    libtirpc-devel \
#    zlib-devel \
#    perl-File-Compare 

#Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    make -j"$compile_cores"

#Run tests

