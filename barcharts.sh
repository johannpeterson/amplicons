#!/bin/zsh

if [[ -n "$1" ]]; then
    EXPNAME=$1
else
    echo "Please provide the experiment name on the command line."
    exit 1
fi

MAXROWS=5
file_list=""
title_list=""

mkdir splits
rm splits/*

SOURCE_FILE=$EXPNAME"_barcode_groups.tsv"
N_SAMPLES=$(csvtk -t summary -w 0 -f sample:countuniq $SOURCE_FILE | tail -n 1)
MAX_COUNT=$(csvtk -t summary -w 0 -f count:max $SOURCE_FILE | tail -n 1)

echo $EXPNAME
echo "source file: "$SOURCE_FILE
echo "N_SAMPLES: "$N_SAMPLES
echo "MAX_COUNT: "$MAX_COUNT

csvtk -t -T split -o splits/ -f "sample" $SOURCE_FILE

for f in $(ls splits/*.tsv); do
    basename=$f:t:r
    title=${basename#${EXPNAME}_barcode_groups-}
    # echo $title
    head -n $[$MAXROWS+1] $f > splits/$basename".split.tsv"
    file_list+=splits/$basename".split.tsv "
    title_list+=$title" "
done

file_list="${file_list%" "}"
title_list="${title_list%" "}"
echo $file_list
echo
echo $title_list

gnuplot -e "files='$file_list'" \
        -e "titles='$title_list'" \
        -e "max_count='$MAX_COUNT'" \
        -e "max_rows='$MAXROWS'" \
        -e "experiment='$EXPNAME'" \
        barcharts.gnuplot
