#!/bin/bash

set -e

#PATH=$PATH:$PWD/bazel/output
##export HOME=$PWD/tensorflow_build/
##mkdir -p $HOME
#
#java=`which java`
#if [ "$JAVA_HOME" != "" ]; then
#  java=$JAVA_HOME/bin/java
#fi
#
#java_version=`$java -version 2>&1 | head -n 1 | awk '{print $3}' | sed s=\"==g`
#good_version=`echo 1.8 $java_version | awk '{if($1<$2)print 1; else print 0}'`
#if [ $good_version -eq 0 ]; then
#  echo You have jdk version = $java_version, which is older than 1.8
#  echo You need to download a later than 1.8 JDK version at
#  echo http://www.oracle.com/technetwork/pt/java/javase/downloads/jdk8-downloads-2133151.html
#  echo and set your JAVA_HOME to point to where it is installed
#  exit 1
#else
#  echo You have jdk version = $java_version, which is newer than 1.8. We will continue the installation
#fi
#
#
#[ ! -f bazel.zip ] && wget --no-check-certificate https://github.com/bazelbuild/bazel/releases/download/0.5.4/bazel-0.5.4-dist.zip -O bazel.zip
#mkdir -p bazel
#cd bazel
#unzip ../bazel.zip
#./compile.sh
#cd ../

 $1 <bool> install with GPU support?

if [[ ${1} == "true" ]]; then
    tf_type=gpu
else
    tf_type=cpu
fi

# assumes bazel is already built
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
if [[ ${tf_type} == "true" ]]; then
    export TF_NEED_CUDA=1
fi
./configure

tensorflow/contrib/makefile/download_dependencies.sh
bazel build -c opt //tensorflow:libtensorflow.so
bazel build -c opt //tensorflow:libtensorflow_cc.so

echo Building tensorflow completed. You will need to go to kaldi/src/ and do
echo \"make\" under tensorflow/ and tfbin/ to generate the binaries

# the following would utilize the highest optimization but might not work in a
# grid where each machine might have different configurations
bazel build --config=opt //tensorflow:libtensorflow.so
bazel build --config=opt //tensorflow:libtensorflow_cc.so


#
## check for expected variable
#if [ -z ${KALDI_PATH} ]; then
#    printf "This script was intended to be run inside a Docker container\n"
#    printf "where the variable KALDI_PATH contains the full path to the kaldi repo.\n"
#    printf "Set this and then rerun\n"
#    exit 1
#fi
#
#location=${KALDI_PATH}/tools/
#mkdir -p ${location}
#
##curl -L \
##    "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${tf_type}-linux-x86_64-1.3.0.tar.gz" |
##    tar -C ${location} -xz
#cd ${location}
#git clone https://github.com/tensorflow/tensorflow
#
#ldconfig
#
#export LIBRARY_PATH=${LIBRARY_PATH}:${location}/tensorflow
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${location}/tensorflow
