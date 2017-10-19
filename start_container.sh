#!/usr/bin/env bash

# starts existing container
# must currently be run from kaldi root

<<<<<<< HEAD
=======
# -p which port to open up for jupyter access

>>>>>>> b59f4d7a3eb5e9517b7b523ed17ab6d67e7eee1e
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
docker run -it --rm -p $port:$port \
    -v `pwd`/egs:/home/kaldi/egs \
    docker-kaldi-instructional