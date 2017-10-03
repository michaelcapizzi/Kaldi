#!/usr/bin/env bash

# This script tries to confirm that installations were correctly completed

# check for expected variable
if [ -z ${KALDI_PATH} ]; then
    printf "this script was intended to be run inside a Docker container\n"
    printf "where the variable $KALDI_PATH contains the full path to the kaldi repo\n"
    printf "set this and then rerun\n"
    exit 1
fi

# source file with some path info
. ${KALDI_PATH}/egs/INSTALLATION/path.sh

##########
# IRSTLM #
##########
IRSTLM=${KALDI_PATH}/tools/irstlm
if [[ `expr index ${PATH} ${IRSTLM}` != 0 ]]; then
    export IRSTLM=${IRSTLM}
    export PATH=${PATH}:${IRSTLM}/bin
fi
build-lm.sh -h || (printf "irstlm not correctly installed or linked" && exit 1)

#####################
# tensorflow (python)
#####################
python -c "import tensorflow as tf" || (printf "tensorflow (python) not correctly installed" \
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
cd ${TENSORFLOW_CC}
gcc -I${TENSORFLOW_CC}/include -L${TENSORFLOW_CC}/lib ${TENSORFLOW_CC}/hello_world.c -ltensorflow
${TENSORFLOW_CC}/a.out || (printf "tensorflow_c not correctly installed" && exit 1)

# remove compiled test script
rm ${TENSORFLOW_CC}/a.out

#########
# openfst
#########
#fstinfo --help || (printf "openfst not correctly installed or linked" && exit 1)