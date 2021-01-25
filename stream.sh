#!/bin/bash

set -ue

lx() {
    printf "%.2f" $(curl -s livingroom.local/sensor/livingroom_illuminance | jq '.value') || true
}

donations() {
    token=$(cat token.json | jq '.access_token' | tr -d \")

    curl -s -X GET https://www.donationalerts.com/api/v1/alerts/donations \
        -H "Authorization: Bearer $token"
}

donations_format() {
    d=$(donations)
    username=$(jq '.data[0].username' <<< $d | tr -d \")
    message=$(jq '.data[0].message' <<< $d)
    amount=$(jq '.data[0].amount' <<< $d)
    currency=$(jq '.data[0].currency' <<< $d | tr -d \")

    echo "$message"
    echo
    echo "$username, $amount $currency"
}

genpng() {
    while true; do
        t=$(curl -s livingroom.local/sensor/outside | jq '.state' | tr -d '"')
        label="$(date +%R)  $t  $(lx) lux"
        echo "$label"
        gm convert -background none -font /usr/share/fonts/liberation/LiberationSerif-Regular.ttf \
            -pointsize 32 -fill 'rgba(64,64,64,100)' \
            label:"$label" overlay.png

        d=$(donations_format)
        echo "$d"
        gm convert -size 300x400 -background transparent -fill 'rgba(64,128,64,100)' \
            -font /usr/share/fonts/liberation/LiberationSerif-Regular.ttf \
            -pointsize 24 caption:"$d" donation.png

        gm montage overlay.png donation.png -background transparent -tile 1x2 -geometry +0+0 overlay2.png
        sleep 10
    done
}

genpng &

pidof jackd || jackd --realtime -d dummy --capture 0 --playback 0 --rate 48000 &
sleep 1
pidof zita-n2j || zita-n2j --chan 1 0.0.0.0 7777
sleep 1

ttoken=$(cat .ttoken)

while read msg;
do
    echo $msg

    if [ "$msg" = "online" ]; then
        pidof ffmpeg && continue
        ffmpeg -f jack -thread_queue_size 1024 -ac 1 -i ffmpeg -c:a aac \
            -r 50 -probesize 32M -i tcp://alarmpi4.local:3333 \
            -f image2 -re -stream_loop -1 -i overlay2.png \
            -filter_complex "overlay=10:10" \
            -g 100 \
            -strict experimental -threads 4 -c:v libx264 -map 0:a -map 1:v -preset ultrafast \
            -b:a 320k -ar 48000 \
            -f flv "rtmp://live.twitch.tv/app/$ttoken" \
            &
        sleep 3
        jack_connect zita-n2j:out_1 ffmpeg:input_1
    fi

   if [ "$msg" = "offline" ]; then
       killall ffmpeg || true
    fi

done < <(mosquitto_sub -h acer.local -t local/birdfeeder/status)

