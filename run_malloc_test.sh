#!/bin/bash
if [ $# -eq 1 ]; then
    make clean && make -j$(nproc) 
fi
cd benchmark/gapbs
export HMALLOC_JEMALLOC=1
export HMALLOC_NODEMASK=4
export HMALLOC_MPOL_MODE=2
numactl --cpunodebind=0 ./bc -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i4 -n1