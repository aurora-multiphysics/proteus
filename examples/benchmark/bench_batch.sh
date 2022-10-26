#!/bin/bash

for ((numprocs=1; numprocs<=$1; numprocs++)); do
  /usr/bin/time -v mpirun -np $numprocs proteus-opt -t -i diffusion_3D_32.i &>> bench_batch.out
done
for ((numprocs=1; numprocs<=$1; numprocs++)); do
  /usr/bin/time -v mpirun -np $numprocs proteus-opt -t --distributed-mesh -i diffusion_3D_32.i &>> bench_batch.out
done
