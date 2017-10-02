# docker-kaldi-instructional - A simplified version of Kaldi in Docker

FROM ubuntu:16.04
MAINTAINER Michael Capizzi <mcapizzi@email.arizona.edu>

# ENV variables
ENV HOME=/home/
ENV SHELL=/bin/bash
ENV KALDI_PATH=${HOME}/kaldi/
ENV KALDI_INSTRUCTIONAL_PATH=${HOME}/kaldi/egs/INSTRUCTIONAL

# install dependencies
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    git \
    python \
    python-setuptools \
    python-numpy \
    python-dev \
    python-pip \
    python-wheel \
    tmux \
    ffmpeg \
    # kaldi requirements
    g++ \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip

# install bash jupyter kernel
RUN pip install jupyter
RUN pip install bash_kernel ; python -m bash_kernel.install

# clone kaldi_instructional
WORKDIR ${HOME}
RUN git clone https://github.com/michaelcapizzi/kaldi.git

# install kaldi-specific dependencies
WORKDIR kaldi/tools
RUN extras/check_dependencies.sh

