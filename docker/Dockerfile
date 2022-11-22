#Docker file to be built within the Proteus docker directory
#Command to build the image: docker build --rm -t proteus:latest .

#Get latest base MOOSE image
FROM idaholab/moose:latest

#Set author of the image
#MAINTAINER Alexander Whittle

#By default 2 cores are used to compile
ARG compile_cores=2

#By default ubuntu is the OS used to build the image
ARG OS="ubuntu" 

#Install pre-requisites for Ubuntu or Fedora
RUN if $OS="ubuntu"; then \
    apt-get update && apt-get install -y\
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
        libboost-filesystem-dev ;\
    fi

RUN if $OS="fedora"; then \
    dnf -y install \
        gcc-c++ \
        gcc-fortran \
        python3-devel \
        openmpi-devel \
        libtirpc-devel \
        zlib-devel \
        perl-File-Compare ;\
    fi

#Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    make -j"$compile_cores"

#Run tests
RUN cd /proteus && \
    ./run_tests