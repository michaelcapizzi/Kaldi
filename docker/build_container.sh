#!/usr/bin/env bash

# script to begin the docker build process
# NOTE: **MUST** be run from docker/

# OPTIONAL ARGUMENTS
# -g = set GPU_SUPPORT to true
# -m = set amount of memory docker can use during build

gpu=false
mem=2g

while getopts "gm:" opt; do
    case ${opt} in
        g)
            gpu=true
            ;;
        m)
            mem=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

if [[ ${gpu} == true ]]; then
    docker build \
        -f GPU/Dockerfile \
        -m ${mem} \
        --build_arg MEM=${mem} \
        -t docker-kaldi-instructional ../
else
    docker build \
        -f CPU/Dockerfile \
        -m ${mem} \
        --build_arg MEM=${mem} \
        -t docker-kaldi-instructional ../
fi