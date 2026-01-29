#!/bin/bash
source benchmark/script/run_common.sh
source benchmark/script/run_measure_latency.sh
export OMP_NUM_THREADS=120

pushd benchmark/gapbs
REBUILD=$1
if [ $REBUILD -eq 1 ]; then
    echo "rebuilding...."
    make clean && make -j$(nproc) 
fi


MODE=${2:-111}   
if [ "$MODE" == "latency" ]; then
    mkdir -p bc_run 
    pushd bc_run
    run_and_measure_latency  $(realpath ../bc) -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i2 -n2
    popd
    mkdir -p pr_run
    pushd pr_run
    run_and_measure_latency $(realpath ../pr) -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i2 -n2
    popd    
else
    mkdir -p bc_run 
    pushd bc_run
    run_and_analyze $MODE $(realpath ../bc) -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i2 -n2
    popd

    mkdir -p pr_run
    pushd pr_run
    run_and_analyze $MODE $(realpath ../pr) -f /home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand.sg -i2 -n2
    popd
fi


popd