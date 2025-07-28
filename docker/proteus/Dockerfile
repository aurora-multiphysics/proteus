# Ignore warnings for not pinning versions in pip, apt-get install.
# hadolint global ignore=DL3008,DL3013

# To build the Docker container, run the following lines from your proteus root directory:
# cd docker
# docker build --rm -t proteus:latest .

# Use proteus-deps as the base image
FROM alexanderianblair/proteus-deps

# By default, build without code coverage flags
ARG coverage=false
# By default checkout main branch from aurora-multiphysics/proteus
ARG build_git_sha=main
ARG build_git_repo=aurora-multiphysics/proteus

# Clone Proteus repository
WORKDIR /$PROTEUS_DIR/../
RUN git clone https://github.com/$build_git_repo
WORKDIR /$PROTEUS_DIR
RUN git checkout $build_git_sha

# Build Proteus
WORKDIR /$PROTEUS_DIR
RUN make -j$MOOSE_JOBS coverage=$coverage

# Build Proteus docs
WORKDIR /$PROTEUS_DIR
RUN doxygen doc/content/doxygen/Doxyfile
WORKDIR /$PROTEUS_DIR/doc
RUN ./moosedocs.py build

# Test Proteus regression tests
WORKDIR /$PROTEUS_DIR
RUN make test

# Build Proteus unit tests
WORKDIR /$PROTEUS_DIR/unit
RUN make -j$MOOSE_JOBS

# Test Proteus unit tests
WORKDIR /$PROTEUS_DIR/unit
RUN make test

# Set working directory
WORKDIR /$PROTEUS_DIR

# Set entrypoint
ENTRYPOINT ["/bin/bash"]
