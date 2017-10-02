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

docker build \
    --build-arg GPU_SUPPORT=${gpu} \
    -f ../../Dockerfile \
    -t docker-kaldi-instructional ../..