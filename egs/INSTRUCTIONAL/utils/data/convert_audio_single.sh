#!/usr/bin/env bash

# converts single audio file to PCM using `ffmpeg`
# It will *automatically* add PCM encoding, and will *optionally* downsample

# ARGUMENTS
# REQUIRED
# -i <path> = full path to audio file to convert
# -o <path> = full path to put converted audio file
# OPTIONAL
# -s <int> = resample rate
# -r = if present, will remove original audio

remove=false
verbose=false

while getopts "i:o:s:rv" opt; do
    case ${opt} in
        i)
            in=${OPTARG}
            ;;
        o)
            out=${OPTARG}
            ;;
        s)
            sample_rate=${OPTARG}
            ;;
        r)
            remove=true
            ;;
	v)
	    verbose=true
	    ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

if [ ${verbose} == true ]; then
    echo "converting audio file ${in} and saving to ${out}"
fi

if [ ! -z ${sample_rate} ]; then
    ffmpeg -loglevel error -i ${in} -ar ${sample_rate} ${out}
else
    ffmpeg -loglevel error -i ${in} ${out}
fi

if [ ${remove} == true ]; then
    rm ${in}
fi
