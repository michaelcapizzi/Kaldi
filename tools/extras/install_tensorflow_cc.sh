#!/bin/bash

# $1 <bool> install with GPU support?

if [[ ${1} == "true" ]]; then
    tf_type=gpu
else
    tf_type=cpu
fi

location=${KALDI_PATH}/tools/tensorflow
mkdir -p ${location}

curl -L \
    "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${tf_type}-linux-x86_64-1.3.0.tar.gz" |
    tar -C ${location} -xz

ldconfig

export LIBRARY_PATH=${LIBRARY_PATH}:${location}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${location}
