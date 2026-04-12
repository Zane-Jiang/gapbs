#!/bin/bash
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-120}
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

BFS_GRAPH_SCALE=${BFS_GRAPH_SCALE:-27}

BFS_TRIALS=${BFS_TRIALS:-10}

BFS_GRAPH_PATH="/home/jz/PCXL/benchmark/gapbs/benchmark/benchmark/graphs/urand_u${BFS_GRAPH_SCALE}.sg"
GRAPH_DIR="$(dirname "${BFS_GRAPH_PATH}")"
if [ ! -f "${BFS_GRAPH_PATH}" ]; then
    echo "graph not found, generating ${BFS_GRAPH_PATH}"
    mkdir -p "${GRAPH_DIR}"
    if [ ! -x ./converter ]; then
        make converter
    fi
    ./converter -u${BFS_GRAPH_SCALE} -k16 -b "${BFS_GRAPH_PATH}"
fi

if [ ! -f "${CC_GRAPH_PATH}" ]; then
    echo "graph not found, generating ${CC_GRAPH_PATH}"
    mkdir -p "${GRAPH_DIR}"
    if [ ! -x ./converter ]; then
        make converter
    fi
    ./converter -u${CC_GRAPH_SCALE} -k16 -b "${CC_GRAPH_PATH}"
fi


mkdir -p bfs_run
pushd bfs_run
run_and_analyze $MODE $(realpath ../bfs) -f "${BFS_GRAPH_PATH}" -n "${BFS_TRIALS}"
popd

popd
