#!/bin/bash

# script to be run on first boot of instance

# pull repository
cd /home
git clone https://github.com/michaelcapizzi/kaldi.git
wait
cd kaldi
git checkout kaldi_instructional
wait

# back up /etc/group
cp /etc/group /etc/group.original
wait

# add mcapizzi and bjoyce to to /etc/group
sed -i.bak -E "s%(users:x:[0-9]+:[a-z,]+)%\1mcapizzi,bjoyce3,%" /etc/group
