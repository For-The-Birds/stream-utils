#!/bin/bash -e
set -eu

. tglib.sh
. VARS.sh


birdnet() {
    meta='{ "week":'$(date +%W)', "lat":55.61, "lon":37.58 }'
    curl --silent localhost:8686/analyze \
        -F meta="$meta" \
        -F audio="@$1;filename=$1" | \
            jq -r '.results[0][0], .results[0][1]' | \
            sed 's/_/ - /; s/\n//;'
}


process_audio_() {
    [ -z "$1" ] && return
    bn=$(basename $1)
    m=../mp4/$bn.mp4
    flac=../flac/$bn.flac
    tmp_w=/tmp/$bn.wav

    sox $1 $tmp_w gain -n -3

    ffmpeg -i "$tmp_w" \
        -lavfi "[0:a] showspectrum=color=fire:slide=replace:scale=log:data=magnitude:fscale=lin:legend=0:orientation=horizontal:overlap=1:win_func=kaiser:fps=8:start=1000:stop=15000:s=540x960" \
        -c:v libx264 -pix_fmt yuv420p -preset veryslow -crf 36 -tune zerolatency \
        -c:a libopus -b:a 96k \
        -y $m

    sendVideo $ch_audio $m

    flac --silent --best --delete-input-file -o $flac $tmp_w

    rm $1 $tmp_w
}

process_audio() {
    cd /mnt/birds/audio/gate_rec/
    wav=$1
    [ -z "$wav" ] && return
    bn=$(basename $wav)
    vid=../mp4/$bn.mp4
    flac=../flac/$bn.flac
    gain=/tmp/$bn.wav
    png=/tmp/$bn.png
    APILOG=/tmp/$bn.log

    sox $wav $gain gain -n -3
    LD_LIBRARY_PATH=~/src/repos/sox/src/.libs ~/src/repos/sox/src/.libs/sox \
        $gain -n spectrogram -L 10 -f 2048 -h -s -t "$bn" -x 1920 -Y 1080 -z 100 -o $png
    ffmpeg -y -hide_banner -nostdin -loglevel warning \
        -i $png -i $gain \
        -filter:v "scale='trunc(oh*a/2)*2:1080':flags=spline" \
        -c:v libx264 -pix_fmt yuv420p -preset veryslow -crf 32 -tune zerolatency \
        -c:a libopus -b:a 96k \
        -movflags +faststart \
        $vid
    sendVideo $ch_audio $vid

    flac --silent --best --delete-input-file -o $flac $wav

    rm -f $gain $wav
}

while true; do
    wav=$(inotifywait -q -e close_write --format '%f' /mnt/birds/audio/gate_rec/)
    process_audio $wav &
done

