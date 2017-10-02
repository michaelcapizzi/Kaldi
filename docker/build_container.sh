#!/usr/bin/env bash

# script to begin the docker build process
# NOTE: **MUST** be run from docker/

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
        -f GPU/Dockerfile \
        -t docker-kaldi-instructional ../
else
    docker build \
        -f CPU/Dockerfile \
        -t docker-kaldi-instructional ../
fi