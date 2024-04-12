#!/bin/zsh

# If SOURCE_DIR is unset or empty, use the default of $HOME/bio/amplicons/
if [[ $SOURCE_DIR = *[!\ ]* ]]; then
    # echo "\$SOURCE_DIR contains characters other than space"
    LOCAL_SOURCE_DIR=$SOURCE_DIR
else
    # echo "\$SOURCE_DIR consists of spaces only"
    LOCAL_SOURCE_DIR="$HOME/bio/amplicons"
fi

docker run -it \
       --mount type=bind,source="$(pwd)",target=/home/bio/data \
       --mount type=bind,source="$LOCAL_SOURCE_DIR",target=/home/bio/extsource \
       nijhawanlab/amplicons
