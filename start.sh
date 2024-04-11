#!/bin/zsh

docker run -it \
       --mount type=bind,source="$(pwd)",target=/home/bio/data \
       nijhawanlab/amplicons
