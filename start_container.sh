#!/usr/bin/env bash

# starts existing container
# must currently be run from kaldi root

# -p which port to open up for jupyter access
port=8880

while getopts "p:" opt; do
    case ${opt} in
        p)
            port=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

# cannot link all the way at kaldi root directory
# when I like `pwd`:/home/kaldi
#   none of the compiled C++ code or openfst code shows up
# WHY?
docker run -it --rm -p $port:$port \
    -v `pwd`/egs:/home/kaldi/egs \
    mcapizzi/kaldi_instructional
