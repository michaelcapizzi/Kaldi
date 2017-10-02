Installation Instructions
=========================

## Building an environment

It is *strongly* recommended that you build an environment for this repository.
Although almost all of the code is written in `shell`, we will be using a
`bash` kernel through `jupyter notebook` for ease of use.  And when we
reach the `neural network` section of the course, there *will* be some
`python` used.  `

**NOTE**: All of `kaldi`, however, is built on the use of `python 2`.` 

### using `anaconda`

```
conda create --name=[name_of_env] python=2 jupyter
```

## Installing dependencies

### Install `bash` kernel

This will install the `bash` kernel for the `jupyter` notebook.
```
source activate [name_of_env]    # activate the environment
pip install bash_kernel ; python -m bash_kernel.install
```

### Install `ffmpeg`

This is used for various tasks on the actual audio files.
#### Mac
```
brew install ffmpeg
```

#### Linux
```
sudo apt-get install ffmpeg
```

### Install `kaldi-specific` tools

The tools below are used in various steps of the `kaldi` pipeline, and
all must be installed from the `tools/` directory.

```
cd tools/
```

Check global dependencies by running the following script.  It will
identify any missing dependencies.  

It is **VERY IMPORTANT** that this come back
