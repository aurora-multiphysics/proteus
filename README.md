# Proteus

[![Documentation](https://github.com/aurora-multiphysics/proteus/actions/workflows/pages.yml/badge.svg?branch=main)](https://aurora-multiphysics.github.io/proteus/)
![lint](https://github.com/aurora-multiphysics/proteus/actions/workflows/lint.yml/badge.svg?branch=main)
![build](https://github.com/aurora-multiphysics/proteus/actions/workflows/main.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/aurora-multiphysics/proteus/graph/badge.svg?token=WV2DE9DT53)](https://codecov.io/gh/aurora-multiphysics/proteus)
[![GitHub License](https://img.shields.io/github/license/aurora-multiphysics/proteus)](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)

Proteus is a MOOSE based application for multiphysics simulation.
It is focussed on fluid dynamics and its commonly coupled domains.

## Installation

### Windows
-------

Proteus can be run on Windows by using the Windows Subsystem for Linux (WSL)
and following the instructions for Ubuntu or Linux below.

### Ubuntu
-------

There is an automated build and install process for Ubuntu,
which can be run using the following commands:
``` {.sh}
git clone https://github.com/aurora-multiphysics/proteus
cd proteus
./scripts/install_ubuntu_prerequisites.sh
./scripts/install_ubuntu.sh
```

Please read the install script and verify you understand
and are comfortable with what it is doing.
Once Proteus is built using this script,
you can use Proteus to run an input file as follows:
``` {.sh}
source ~/.proteus_profile
proteus-opt -i <input-file>.i
```

### Other Linux
-------

Install MOOSE by following the instructions
on the [MOOSE homepage](https://www.mooseframework.org/).

Once MOOSE is installed, change to the proteus directory and run:
``` {.sh}
make
```
After this completes successfully, use Proteus to run an input file
as follows:
``` {.sh}
./proteus-opt -i <input-file>.i
```

## Building Using Multiple Cores
-------

The install process above can be sped up
by using multiple cores during the build process.
Note that this will also need more memory
and to ensure the build goes smoothly,
we recommend having at least 4GB per core.
Multiple cores are enabled
by setting the MOOSE JOBS environment variable
before running the install script:
``` {.sh}
export MOOSE_JOBS=4
```
Where the number 4 in the example above corresponds to using four cores.

## Docker
-------

Proteus can be run in a container to make installation easier.

Run this command in the /docker directory to build the image.
``` {.sh}
docker build --rm -t proteus:latest .
```

## Contributors

Aleksander J. Dubas,
UK Atomic Energy Authority

Rupert W. Eardley-Brunt,
UK Atomic Energy Authority

Luke Humphrey,
UK Atomic Energy Authority

Alexander Whittle,
UK Atomic Energy Authority

Bill Ellis,
UK Atomic Energy Authority

Pranav Naduvakkate,
UK Atomic Energy Authority

Matthew Falcone,
UK Atomic Energy Authority
