#!/bin/bash -e

. tglib.sh
. VARS.sh

birdnet() {
    meta='{ "week":'$(date +%W)', "lat":55.61, "lon":37.58 }'
    curl localhost:8686/analyze \
        -F meta="$meta" \
        -F audio="@$1;filename=$1" | \
            jq -r '.results[0][0]' | \
            sed 's/_/ - /'
}

process_audio() {
    [ -z "$1" ] && return
    bn=$(basename $1)
    wav=$WAVD/$bn
    opus=$OPUSD/$bn.opus
    flac=$FLACD/$bn.flac
    gain=$OPUSD/$bn-gain.wav
    png=$PNGD/$bn.png
    sox $wav $gain gain -n -3
    sox $gain -n spectrogram -h -s -t "$bn" -x 1920 -Y 1080 -z 100 -o $png
    opusenc --quiet --bitrate 128 --artist birds --date $(date +%F) $gain $opus
    o=${opus%%.wav.opus}
    ln -s $opus $o
    sendPhoto $ch_audio $png "$bn"$'\n'"$(birdnet $wav)" >/dev/null
    sendAudio $ch_audio $o >/dev/null
    #tglog $ch_audio "$(sox -M -c 1 $wav -c 1 $gain -n stats |& grep dB)"
    flac --silent --best --delete-input-file -o $flac $wav
    rm $o $png $gain
}

while true; do
    wav=$(inotifywait -q -e close_write --format '%f' /mnt/birds/audio/gate_rec/)
    process_audio $wav &
done

