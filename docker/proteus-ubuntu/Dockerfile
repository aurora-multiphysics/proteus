#Final layer of build for Proteus image
#Docker file to be built within the Proteus main directory

# Get MOOSE base image already built 
FROM 

# By default 4 cores are used to compile
ARG compile_cores=4

# Should we generate a coverage report
ARG test_coverage=false

# Coverage repo token
ARG coveralls_token=""

# Branch name for coveralls
ARG coveralls_branch=""

# Install extra packages if we want test coverage
RUN if "$test_coverage" ; then \
       apt-get update && \
       apt-get install -y python3-pip && \
       pip install cpp-coveralls && \
       pip install coveralls && \
       pip install gcovr; \
    fi

# Copy entire repository into image
COPY ./ /home/proteus/

# Build
RUN if "$test_coverage" ; then \
    

# Generate test coverage report using coveralls and upload
RUN if "$test_coverage" && ! [ "$coveralls_token" = "" ] ; then \

    fi

# Run examples
RUN cd /home/proteus/ && \
    ./run_tests