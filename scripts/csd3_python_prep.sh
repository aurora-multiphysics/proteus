#!/bin/bash

# This scripts installs python pre-requisites for Proteus on CSD3.
# It should be run once before the install script.

module load python/3.11.0-icl
pip3.11 install --user --upgrade packaging
pip3.11 install --user --upgrade pyyaml
pip3.11 install --user --upgrade jinja2
