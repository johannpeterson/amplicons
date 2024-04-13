#!/bin/bash
/home/bio/extsource/barchart_grid.py \
    --debug \
    --top 10 \
    --experiment $1 \
    --control W1 --control W2 --control W3 \
    --png ./aligned/$1_barchart.png \
    ./aligned/$1_barcode_counts_samples.tsv \
    ./aligned/$1_top_10.tsv 2>>./aligned/VK031.log
