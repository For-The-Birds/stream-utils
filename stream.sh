#!/bin/bash

bash genpng.sh &

pidof jackd || jackd --realtime -d dummy --capture 0 --playback 0 --rate 48000 &
sleep 1
pidof zita-n2j || zita-n2j --chan 1 0.0.0.0 7777
sleep 1

ttoken=$(cat .ttoken)
ytoken=$(cat .ytoken)
f="f=fifo:fifo_format=flv:drop_pkts_on_overflow=1:attempt_recovery=1:recovery_wait_time=1"
while read msg;
do
    echo $msg

    if [ "$msg" = "online" ]; then
        pidof ffmpeg && continue
        ffmpeg -f jack -thread_queue_size 2048 -ac 1 -i ffmpeg -c:a aac \
            -r 50 -probesize 32M -thread_queue_size 2048 -i tcp://alarmpi4.local:3333 \
            -f image2 -re -stream_loop -1 -i overlay.png \
            -filter_complex "overlay=10:10" \
            -g 100 \
            -strict experimental -threads 4 -c:v libx264 -map 0:a -map 1:v -preset ultrafast \
            -c:a aac -q:a 1 -ar 48000 -movflags +faststart \
            -drop_pkts_on_overflow 1 -attempt_recovery 1 -recover_any_error 1 \
            -f flv "rtmp://live.twitch.tv/app/$ttoken" \
            &
            #-f tee "[$f]rtmp://live.twitch.tv/app/$ttoken" \
            #-f tee "[$f]rtmp://a.rtmp.youtube.com/live2/$ytoken|[$f]rtmp://live.twitch.tv/app/$ttoken" \
            #-f fifo -fifo_format flv \
            #"rtmp://live.twitch.tv/app/$ttoken" \
            #&
        sleep 3
        jack_connect zita-n2j:out_1 ffmpeg:input_1
    fi

   if [ "$msg" = "offline" ]; then
       killall ffmpeg || true
    fi

done < <(mosquitto_sub -h acer.local -t local/birdfeeder/status)

