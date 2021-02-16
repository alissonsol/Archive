#!/bin/bash

DATA_DIR="/mnt/storage/gpt2/input/"
mkdir -p $DATA_DIR
DATA_INITIALIZED="${DATA_DIR}/initialized"

if [ ! -e $DATA_INITIALIZED ]; then
    echo "-- Preparing data --"
    cd /tmp
    curl -O https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-v1.zip
    sleep 1
    unzip -o wikitext-103-v1.zip
    ls -la wikitext-103
    sleep 1
    mv -f wikitext-103/* $DATA_DIR
    ls -la $DATA_DIR
    touch $DATA_INITIALIZED
else
    echo "-- Data already prepared --"
fi
echo "-- Done for this run --"