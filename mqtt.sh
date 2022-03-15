#!/bin/bash

#[ "$(<.status)" = "online" ] && systemctl --user restart streamutil@savepi.sh.service

set -vx

avconcat() {
    ffmpeg -i /mnt/birds/pivid/$(<.date).mkv \
        -i /mnt/birds/audio/$(<.date).opus \
        -map 0:0 -map 1:0 \
        -c:v copy \
        -af adelay=5000,aresample=async=1 -c:a libopus \
        /mnt/nvme/pivid/$(<.date)_cat.mkv || return
    mv -v /mnt/birds/audio/$(<.date).opus /mnt/birds/audio/$(<.date)_done.opus
    mv -v /mnt/nvme/pivid/$(<.date)_cat.mkv /mnt/birds/pivid/$(<.date).mkv &
}

while read msg; do
    echo "mqtt message: $msg" #| tee .status
    case "$msg" in
    off)
        systemctl --user stop streamutil@savepi.sh.service
        #systemctl --user stop streamutil@savepi2.sh.service
        #systemctl --user stop streamutil@savertsp.sh.service
        systemctl --user stop streamutil@webcam-save-stream.sh.service
        ;;
    on)
        systemctl --user restart streamutil@savepi.sh.service
        #systemctl --user restart streamutil@savepi2.sh.service
        #systemctl --user restart streamutil@savertsp.sh.service
        systemctl --user restart streamutil@webcam-save-stream.sh.service
        ;;
    online)
        systemctl --user restart streamutil@gaterec.sh
        systemctl --user restart streamutil@audio_rec.sh.service
        systemctl --user restart streamutil@genpng.sh.service
        systemctl --user restart streamutil@twitch.sh.service
        ;;
    offline)
        systemctl --user stop streamutil@twitch.sh.service
        systemctl --user stop streamutil@genpng.sh.service
        systemctl --user stop streamutil@gaterec.sh
        systemctl --user stop streamutil@audio_rec.sh.service
        ;;
    esac
done < <(mosquitto_sub -h mqtt.local $(<.mqttcreds) -t local/birdfeeder/status)
