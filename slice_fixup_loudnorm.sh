#!/bin/bash

set -vxe

ln=$(ffmpeg -loglevel info -y -i $1 -vn -filter:a loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json \
    -f null /dev/null |& awk '/{/,EOF')

duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration \
    -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$1")

i_i=$(jq -r '.input_i' <<< "$ln")
i_lra=$(jq -r '.input_lra' <<< "$ln")
i_tp=$(jq -r '.input_tp' <<< "$ln")
i_thresh=$(jq -r '.input_thresh' <<< "$ln")

lra=10
#(( $(echo "$lra < 5" | bc -l) )) && lra=17



ffmpeg -hide_banner -nostdin -y \
    -i "$1" \
    -af adelay=$2,loudnorm=linear=true:\
I=-16:TP=-1.5:LRA=$lra:\
measured_I=$i_i:measured_LRA=$i_lra:measured_tp=$i_tp:measured_thresh=$i_thresh:\
print_format=summary \
    -to $duration \
    -c:v copy -c:a libopus \
    "/mnt/nvme/pivid/$3"

# loudnorm=linear=true:measured_I=$i_i:measured_LRA=$i_lra:measured_tp=$i_tp:measured_thresh=$i_thresh
