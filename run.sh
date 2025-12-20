#!/bin/bash
source benchmark/script/run_common.sh
export OMP_NUM_THREADS=120

pushd benchmark/gapbs
REBUILD=$1
if [ $REBUILD -eq 1 ]; then
    echo "rebuilding...."
    make clean && make -j$(nproc) 
fi

MODE=${2:-111}   
run_and_analyze $MODE $(realpath ./bc) ./bc -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i4 -n1
popd