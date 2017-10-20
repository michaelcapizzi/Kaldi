#!/usr/bin/env bash

# converts audio to PCM using `flac`
# It will *automatically* add PCM encoding, and will *optionally* downsample

# ARGUMENTS
# REQUIRED
# -i <path> = full path to audio file to convert
# -o <path> = full path to put converted audio file
# OPTIONAL
# -s <int> = resample rate
# -r = if present, will remove original audio

remove=false

while getopts "i:o:s:r" opt; do
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
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

echo "converting audio file ${in} and saving to ${out}"

if [ ! -z ${sample_rate} ]; then
    ffmpeg -i ${in} -ar ${sample_rate} ${out}
else
    ffmpeg -i ${in} ${out}
fi

if [ ${remove} == true ]; then
    rm ${in}
fi
