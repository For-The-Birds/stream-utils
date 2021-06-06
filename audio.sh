#!/bin/bash -e

. tglib.sh
. VARS.sh

process_audio() {
    [ -z "$1" ] && return
    bn=$(basename $1)
    wav=$WAVD/$bn
    opus=$OPUSD/$bn.opus
    flac=$FLACD/$bn.flac
    gain=$OPUSD/$bn-gain.wav
    png=$PNGD/$bn.png
    sox $wav $gain gain -n -3
    sox $gain -n spectrogram -h -t "$bn" -Y 1080 -z 100 -x 1920 -o $png
    opusenc --bitrate 128 --artist birds --date $(date +%F) $gain $opus
    o=${opus%%.wav.opus}
    ln -s $opus $o
    sendPhoto $ch_audio $png "$bn"
    sendAudio $ch_audio $o
    #tglog $ch_audio "$(sox -M -c 1 $wav -c 1 $gain -n stats |& grep dB)"
    flac --best --delete-input-file -o $flac $wav
    rm $o $png $gain
}

while true; do
    wav=$(inotifywait -q -e close_write --format '%f' /mnt/birds/audio/gate_rec/)
    process_audio $wav &
done

