#!/usr/bin/env bash

docker run -it -p 8888:8888 \
    -v `pwd`:/home/kaldi/ \
    docker-kaldi-instructional