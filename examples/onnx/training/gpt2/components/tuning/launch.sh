#!/bin/bash
  
CMD=${1:-/bin/bash}
NV_VISIBLE_DEVICES=${2:-"all"}
DOCKER_BRIDGE=${3:-"host"}
DATA_DIR="/mnt/storage/gpt2/input/"
RESULTS_DIR="/mnt/storage/gpt2/results/"

echo "-- launch started --"
# docker run -it --rm \
#   --gpus device=$NV_VISIBLE_DEVICES \
#   --net=$DOCKER_BRIDGE \
#   --shm-size=1g \
#   --ulimit memlock=-1 \
#   --ulimit stack=67108864 \
#   -v $DATA_DIR:/data/ \
#   -v $PWD:/workspace/ \
#   -v $PWD/results:/results \
#   --workdir=/workspace/ \
#   onnxruntime-gpt $CMD

mkdir -p $RESULTS_DIR
ln -s $DATA_DIR /data
ln -s $RESULTS_DIR /results
cd /workspace

echo "-- data --"
ls -la /data

echo "-- results --"
ls -la /results

echo "-- launch ended --"
