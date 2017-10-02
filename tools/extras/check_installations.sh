#!/usr/bin/env bash

# This script tries to confirm that installations were correctly completed

# check for expected variable
if [ -z ${KALDI_PATH} ]; then
    printf "this script was intended to be run inside a Docker container\n"
    printf "where the variable $KALDI_PATH contains the full path to the kaldi repo\n"
    printf "set this and then rerun\n"
    exit 1
fi

# source ths path.sh file
${KALDI_PATH}/path.sh

##########
# IRSTLM #
##########

build-lm.sh

#####################
# tensorflow (python)
#####################
python -m "import tensorflow as tf" || (printf "tensorflow (python) not correctly installed" \
    && exit 1)

################
# tensorflow (C)
################
TENSORFLOW_CC=${KALDI_PATH}/tools/tensorflow
# write test script
printf "#include <stdio.h>\\n#include <tensorflow/c/c_api.h>\n\n" > ${TENSORFLOW_CC}/hello_world.c
printf "int main() {\n    printf(\"TF C code works\");\n    return 0;\n}" \
    >> ${TENSORFLOW_CC}/hello_world.c
# run test script
gcc -I${TENSORFLOW_CC}/include -L${TENSORFLOW_CC}/lib ${TENSORFLOW_CC}/hello_world.c -ltensorflow
${TENSORFLOW_CC}/a.out || (printf "tensorflow_c not correctly installed" && exit 1)

# remove compiled test script
${TENSORFLOW_CC}/a.out
