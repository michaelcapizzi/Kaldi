# docker-kaldi-instructional - A simplified version of Kaldi in Docker

FROM ubuntu:16.04
MAINTAINER Michael Capizzi <mcapizzi@email.arizona.edu>

# ENV and ARG variables
ARG HOME=/home/
ENV SHELL=/bin/bash
ENV KALDI_PATH=${HOME}/kaldi
ENV KALDI_INSTRUCTIONAL_PATH=${KALDI_PATH}/egs/INSTRUCTIONAL

# install dependencies
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    git \
    python \
    python3 \
    python-setuptools \
    python-numpy \
    python-dev \
    python-pip \
    python-wheel \
    tmux \
    ffmpeg \
    unzip \
    # kaldi requirements
    g++ \
    libatlas3-base \
    zlib1g-dev \
    make \
    automake \
    autoconf \
    patch \
    bzip2 \
    wget \
    libtool \
    subversion \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install java
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:webupd8team/java -y \
 && apt-get update \
 && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
 && apt-get install -y oracle-java8-installer \
 && apt-get clean

# install CUDA
# copied from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list
ENV CUDA_VERSION 8.0.61
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"
ENV NVIDIA_CUDA_VERSION $CUDA_VERSION
ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-8-0=8.0.61.2-1 \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-8.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*
# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# update pip
RUN pip install --upgrade pip

# install bash jupyter kernel
RUN pip install jupyter bash_kernel ; python -m bash_kernel.install

# clone kaldi_instructional
WORKDIR ${HOME}
RUN git clone https://github.com/michaelcapizzi/kaldi.git
WORKDIR ${KALDI_PATH}
RUN git fetch
RUN git checkout kaldi_instructional

# install kaldi-specific tools
WORKDIR ${KALDI_PATH}/tools
# irstlm
ENV IRSTLM=${KALDI_PATH}/tools/irstlm
RUN extras/install_irstlm.sh
RUN export PATH=${PATH}:${IRSTLM}/bin
# tensorflow (python)
RUN extras/install_tensorflow_py.sh true
# tensorflow (C)
RUN extras/install_tensorflow_cc.sh
# compile tools
#RUN make -j 2

# make sure all dependencies are present
RUN extras/check_dependencies.sh

# compile kaldi source code
#WORKDIR ${KALDI_PATH}/src
#RUN ./configure --shared
#make depend -j 2

# compile TF C code
#WORKDIR ${KALDI_PATH}/src/tfrnnlm
#RUN make -j 2
#WORKDIR ${KALDI_PATH}/src
#RUN make -j 2

WORKDIR ${KALDI_INSTRUCTIONAL_PATH}
