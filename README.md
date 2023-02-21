Proteus
=======

Proteus is a MOOSE based application for multiphysics simulation.
It is focussed on fluid dynamics and its commonly coupled domains.

Installation
============

Windows
-------

Proteus can be run on Windows by using the Windows Subsystem for Linux (WSL)
and following the instructions for Ubuntu or Linux below.

Ubuntu
------

There is an automated build and install process for Ubuntu,
which can be run using the following commands:
```
git clone https://github.com/aurora-multiphysics/proteus
cd proteus
./scripts/install_ubuntu.sh
```

Please read the install script and verify you understand
and are comfortable with what it is doing.
Once Proteus is built using this script,
you can use Proteus to run an input file as follows:
```
source ~/.moose_profile
proteus-opt -i <input-file>.i
```

Other Linux
-----------

Install MOOSE by following the instructions
on the [MOOSE homepage](https://www.mooseframework.org/).

Once MOOSE is installed, change to the proteus directory and run:
```
make
```
After this completes successfully, use Proteus to run an input file
as follows:
```
./proteus-opt -i <input-file>.i
```

Docker
-----

Proteus can be run in a container to make installation easier.

Run this command in the /docker directory to build the image.
```
docker build --rm -t proteus:latest .
```

Contributors
============

Aleksander J. Dubas,
UK Atomic Energy Authority

Rupert W. Eardley,
UK Atomic Energy Authority

Luke Humphrey,
UK Atomic Energy Authority

Alexander Whittle,
UK Atomic Energy Authority
