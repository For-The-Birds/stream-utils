#!/bin/bash

set -ue

f=$1
#inc=${2:-10}
fps=${2:-1/10}
fps=6/1
o="frames/$(basename $f)-frmaes/"

mkdir -p $o
ffmpeg -y -hide_banner -nostdin -loglevel error \
    -i $f \
    -filter:v fps=fps=$fps \
    $o/%08d.jpg

echo "$f done"
exit



# https://stackoverflow.com/a/28321986/17388074 wtf?

vmtouch -m 100G -t $f

duration=$(ffjson.sh $f | jq -r '.format.duration')
fps=$(ffjson.sh $f | jq -r '.streams[0].r_frame_rate')
total_frames=$(bc -l <<< "$duration * $fps")

export fps o f

extract() {
    i=$1
    echo -n "$i "
    ffmpeg -y -hide_banner -nostdin -loglevel error \
        -accurate_seek -ss $(bc -l <<< "$i/$fps") \
        -i $f -frames:v 1 \
        $o/$i.jpg
}
export -f extract

seq -w 00000000 $inc $total_frames | parallel extract

echo
