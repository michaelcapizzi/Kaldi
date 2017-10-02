#!/usr/bin/env bash

# set the global variable MEM as the maximum amount of memory you want to utilize (in gigabytes)

MEM="--mem 2G"

export train_cmd="run.pl ${MEM}"
export decode_cmd="run.pl ${MEM}"
export mkgraph_cmd="run.pl ${MEM}"
