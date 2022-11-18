#Docker file to be built within the Proteus main directory

# Get latest base MOOSE image
FROM idaholab/moose:latest

# By default 2 cores are used to compile
ARG compile_cores=2

#Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
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
    libboost-filesystem-dev \

#Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    make -j"$compile_cores"

#Run tests

