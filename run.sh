#!/bin/bash
export OMP_NUM_THREADS=120
REBUILD=$1
MODE=${2:-111}
if [ "$MODE" == "latency" ]; then
    source benchmark/script/measurement/run_measure_latency.sh
else
    source benchmark/script/run_common.sh
fi

pushd benchmark/gapbs
if [ $REBUILD -eq 1 ]; then
    echo "rebuilding...."
    make clean && make -j$(nproc)
fi

BC_GRAPH_SCALE=${BC_GRAPH_SCALE:-14}
PR_GRAPH_SCALE=${PR_GRAPH_SCALE:-20}
BC_GRAPH_PATH="/home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand_u${BC_GRAPH_SCALE}.sg"
PR_GRAPH_PATH="/home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand_u${PR_GRAPH_SCALE}.sg"
GRAPH_DIR="$(dirname "${BC_GRAPH_PATH}")"
if [ ! -f "${BC_GRAPH_PATH}" ]; then
    echo "graph not found, generating ${BC_GRAPH_PATH}"
    mkdir -p "${GRAPH_DIR}"
    if [ ! -x ./converter ]; then
        make converter
    fi
    ./converter -u${BC_GRAPH_SCALE} -k16 -b "${BC_GRAPH_PATH}"
fi

if [ ! -f "${PR_GRAPH_PATH}" ]; then
    echo "graph not found, generating ${PR_GRAPH_PATH}"
    mkdir -p "${GRAPH_DIR}"
    if [ ! -x ./converter ]; then
        make converter
    fi
    ./converter -u${PR_GRAPH_SCALE} -k16 -b "${PR_GRAPH_PATH}"
fi

if [ "$MODE" == "latency" ]; then
    mkdir -p bc_run
    pushd bc_run
    run_and_measure_latency $(realpath ../bc) -f "${BC_GRAPH_PATH}" -i2 -n5
    popd
    mkdir -p pr_run
    pushd pr_run
    run_and_measure_latency $(realpath ../pr) -f "${PR_GRAPH_PATH}" -i20 -n400
    popd
else
    mkdir -p bc_run
    pushd bc_run
    run_and_analyze $MODE $(realpath ../bc) -f "${BC_GRAPH_PATH}" -i20 -n50
    popd

    mkdir -p pr_run
    pushd pr_run
    run_and_analyze $MODE $(realpath ../pr) -f "${PR_GRAPH_PATH}" -i20 -n400
    popd
fi

popd
