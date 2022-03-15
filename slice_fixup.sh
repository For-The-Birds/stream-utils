#!/bin/bash

set -vxeu

#o="/mnt/nvme/pivid/$3"
o="./$3"

if ffprobe "$1" |& grep Stream | grep Audio; then
    ffmpeg -hide_banner -nostdin -y -loglevel warning \
        -i "$1" \
        -map 0:a \
        -c:a pcm_s16le \
        $o.wav

    sox $o.wav $o.gain.wav gain -n -3

    ffmpeg -hide_banner -nostdin -y -loglevel warning \
        -i "$1" \
        -i $o.gain.wav \
        -map 0:v -map 1:a \
        -c:v copy -c:a libopus \
        $o

    rm -v $o.wav $o.gain.wav
else
    ffmpeg -hide_banner -nostdin -y -loglevel warning \
        -i "$1" \
        -f lavfi -i anullsrc=channel_layout=mono:sample_rate=48000 \
        -map 0:v -map 1:a \
        -c:v copy -c:a libopus \
        -shortest \
        $o
fi

mv -v "$1" .trash/
