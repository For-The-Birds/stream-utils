#!/bin/bash

set -vxeu

#o="/mnt/nvme/pivid/$3"
o="./$3"

ffmpeg -hide_banner -nostdin -y -loglevel warning \
    -i "$1" \
    -map 0:v \
    -c:v copy  \
    $o \
    -map 0:a \
    -c:a pcm_s16le \
    $o.wav

sox $o.wav $o.gain.wav gain -n -3

ffmpeg -hide_banner -nostdin -y -loglevel warning \
    -i $o \
    -i $o.gain.wav \
    -map 0:v -map 1:a \
    -c:v copy -c:a libopus \
    $o.norm.mp4

mv -v $o.norm.mp4 $o
rm -v $o.wav $o.gain.wav
mv -v "$1" .trash/
