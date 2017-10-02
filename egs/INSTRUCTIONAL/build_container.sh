#!/usr/bin/env bash

# OPTIONAL ARGUMENTS
# -g = set GPU_SUPPORT to true

gpu=false

while getopts "g" opt; do
    case ${opt} in
        g)
            gpu=true
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

if [[ ${gpu} == true ]]; then
    docker build \
        -f ../../docker/GPU/Dockerfile \
        -t docker-kaldi-instructional ../..
else
    docker build \
        -f ../../docker/CPU/Dockerfile \
        -t docker-kaldi-instructional ../..
fi