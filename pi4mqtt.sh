#!/bin/bash

set -vx

while read msg; do
    echo "mqtt message: $msg" #| tee .status
    case "$msg" in
    off)
        #systemctl --user stop streamutil@raspivid.sh.service
        systemctl --user stop streamutil@savevideo0.sh.service
        ;;
    on)
        #systemctl --user restart streamutil@raspivid.sh.service
        systemctl --user restart streamutil@savevideo0.sh.service
        ;;
    esac
done < <(mosquitto_sub -h mqtt.lan $(<.mqttcreds) -t local/birdfeeder/status)

