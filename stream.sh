#!/bin/bash

clean() {
    pkill -s 0 -f genpng.sh
    pkill -s 0 -f ffmpeg.sh
    pkill -s 0 -F .ffmpeg.pid ffmpeg
}

trap "clean" SIGINT SIGTERM EXIT

bash genpng.sh &

#pidof jackd || jackd --realtime -d dummy --capture 0 --playback 0 --rate 48000 &
#sleep 1
#pidof zita-n2j || zita-n2j --chan 1 --buff 100 0.0.0.0 7777 &
#sleep 1

bash ffmpeg.sh &
echo $! >.ffmpeg.sh.pid
while read msg; do
    echo $msg | tee .status
    pkill -INT -s 0 -F .ffmpeg.pid ffmpeg
    sleep 1
    pkill -s 0 -f ffmpeg.sh
    sleep 1
    bash ffmpeg.sh &
    echo $! >.ffmpeg.sh.pid
done < <(mosquitto_sub -h acer.local -t local/birdfeeder/status)

