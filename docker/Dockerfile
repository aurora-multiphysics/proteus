# To build the Docker container, run the following lines from your proteus root directory:
# cd docker
# docker build --rm -t proteus:latest .

#Get latest base MOOSE image
FROM idaholab/moose:latest

#By default 2 cores are used to compile
ARG compile_cores=2

#Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    make -j"$compile_cores"

#Run tests
RUN cd /proteus && \
    ./run_tests
