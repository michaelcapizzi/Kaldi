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
    curl \
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
#RUN apt-get update \
# && apt-get upgrade -y \
# && apt-get install -y software-properties-common \
# && add-apt-repository ppa:webupd8team/java -y \
# && apt-get update \
# && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
# && apt-get install -y oracle-java8-installer \
# && apt-get clean

# update pip
RUN pip install --upgrade pip

# install jupyter kernel for bash
RUN pip install jupyter bash_kernel ; python -m bash_kernel.install

# clone kaldi_instructional
WORKDIR ${HOME}
RUN git clone https://github.com/michaelcapizzi/kaldi.git
WORKDIR ${KALDI_PATH}
RUN git fetch
RUN git checkout kaldi_instructional

# make sure all dependencies are present
RUN tools/extras/check_dependencies.sh

# install kaldi-specific tools
WORKDIR ${KALDI_PATH}/tools
# irstlm
ENV IRSTLM=${KALDI_PATH}/tools/irstlm
RUN extras/install_irstlm.sh
RUN export PATH=${PATH}:${IRSTLM}/bin
# tensorflow (python)
RUN extras/install_tensorflow_py.sh false
# tensorflow (C)
RUN extras/install_tensorflow_cc.sh false

# check installations
RUN extras/check_installations.sh

# compile remaining tools
#RUN make -j 2



# compile kaldi source code
#WORKDIR ${KALDI_PATH}/src
#RUN ./configure --shared
#make depend -j 2

# compile tensorflow C code
#WORKDIR ${KALDI_PATH}/src/tfrnnlm
#RUN make -j 2
#WORKDIR ${KALDI_PATH}/src/tfrnnlmbin
#RUN make -j 2
#WORKDIR ${KALDI_PATH}/src
#RUN make -j 2

WORKDIR ${KALDI_INSTRUCTIONAL_PATH}
