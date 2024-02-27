#!/bin/bash

# This scripts installs python pre-requisites for Proteus on CSD3.
# It should be run once before the install script.

module load python/3.8.11
python -m ensurepip --upgrade --user
python -m pip install --user --upgrade pip
python -m pip install --user --upgrade packaging

