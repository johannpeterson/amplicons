# docker build -t $DOCKER_IMAGE .

# Docker image for Nijhawan Lab, UTSW
# Contains:
#       csvtk
#       python

FROM ubuntu:latest
# continuumio/miniconda3
ARG VERSION=0.0.1
LABEL version=$VERSION
LABEL description="Tools for amplicon analysis used by Nijhawan Lab, UTSW"

ENV BIO_USER      bio
ENV BIO_GROUP     bio
ENV HOME_DIR      /home/bio
ENV DATA_DIR      $HOME_DIR/data

# Required executables:
# csvtk
# flash2
# separate_matchtable.awk
# merge_names.awk
# count_barcodes.sh
# get_regexes.py
# count_regex.py
# flatten_samples.py
# barchart_grid.py

# Required python modules:
# argparse
# os
# sys
# csv
# types
# regex
# itertools
# Bio
# re
# email
# matplotlib
# seaborn
# pandas

# ENTRYPOINT ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--no-browser"]

# The recommended way to install packages:
# RUN apt-get update && apt-get install -y \
#   packagename \
#   && rm -rf /var/lib/apt/lists/*

# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt upgrade -y && apt-get --quiet install -y \
    time uuid-runtime curl unzip make \
    build-essential zlib1g-dev \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# COPY requirements.txt /home/bio/requirements.txt
# RUN pip install --upgrade pip
# RUN pip install -r /home/bio/requirements.txt
 
# flash2
# https://github.com/dstreett/FLASH2/archive/refs/heads/master.zip
WORKDIR /usr/bin
RUN ["curl", "-L", "-o", \
    "flash2.zip", \
    "https://github.com/dstreett/FLASH2/archive/refs/heads/master.zip"]
RUN ["unzip", "-o", "flash2.zip"]
WORKDIR /usr/bin/FLASH2-master
RUN make
RUN cp ./flash2 /usr/bin/flash2

# csvtk
# https://github.com/shenwei356/csvtk/releases/download/v0.29.0/csvtk_linux_arm64.tar.gz
WORKDIR /usr/bin
RUN ["curl", "-L", "-o", \
    "csvtk_linux_arm64.tar.gz", \
    "https://github.com/shenwei356/csvtk/releases/download/v0.29.0/csvtk_linux_arm64.tar.gz"]
RUN ["tar", "-xvf", "csvtk_linux_arm64.tar.gz"]

RUN echo "Building for ${BUILDARCH}"

COPY --chown=bio:bio Makefile $HOME_DIR/amplicons/
COPY --chown=bio:bio *.py $HOME_DIR/amplicons/
COPY --chown=bio:bio *.sh $HOME_DIR/amplicons/
COPY --chown=bio:bio *.awk $HOME_DIR/amplicons/

RUN groupadd $BIO_GROUP && \
    useradd --create-home --home-dir $HOME_DIR \
    --gid $BIO_USER \
    --groups sudo \
    $BIO_GROUP

RUN mkdir $DATA_DIR
VOLUME $DATA_DIR

USER $BIO_USER
WORKDIR $HOME_DIR