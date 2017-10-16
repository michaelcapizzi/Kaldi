#!/usr/bin/env bash

# starts existing container
# must currently be run from kaldi root

# cannot link all the way at kaldi root directory
docker run -it -p 8888:8888 \
    -v `pwd`/egs:/home/kaldi/egs \
    docker-kaldi-instructional