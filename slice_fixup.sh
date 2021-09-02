#!/bin/bash

set -vxe

duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration \
    -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$1")
delay=$2
sdelay=$(bc -l <<< "$delay/1000")
sdelay=0.1

o="/mnt/nvme/pivid/$3"

ffmpeg -hide_banner -nostdin -y -loglevel warning \
    -i "$1" \
    -map 0:v \
    -c:v copy  \
    $o \
    -map 0:a \
    -c:a pcm_s16le \
    $o.wav

sox -n -r 48000 -c 1 silence.wav trim 0.0 $sdelay
sox $o.wav $o.gain.wav gain -n -3
sox silence.wav $o.gain.wav $o.pad.wav

ffmpeg -hide_banner -nostdin -y -loglevel warning \
    -to $duration \
    -i $o \
    -to $duration \
    -i $o.pad.wav \
    -map 0:v -map 1:a \
    -c:v copy -c:a libopus \
    $o.norm.mp4

mv -v $o.norm.mp4 $o
rm -v $o.wav $o.gain.wav silence.wav $o.pad.wav

# loudnorm=linear=true:measured_I=$i_i:measured_LRA=$i_lra:measured_tp=$i_tp:measured_thresh=$i_thresh
