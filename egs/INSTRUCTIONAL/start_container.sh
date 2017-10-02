#!/usr/bin/env bash

docker run -it -p 8888:8888 \
    -v `pwd`:/home/kaldi/egs/INSTRUCTIONAL \
    docker-kaldi-instructional