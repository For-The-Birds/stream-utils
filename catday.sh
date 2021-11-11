#!/bin/bash

set -e

for d in $@; do
	ls -1 ${d}_??:??.mp4 | ffmpeg_xfade.sh "$d.mp4"
	mv -v ${d}_??:??.mp4 archive/
done
