#!/bin/bash

#[ "$(<.status)" = "online" ] && systemctl --user restart streamutil@savepi.sh.service

while read msg; do
    echo "$msg" #| tee .status
    case "$msg" in
    offlie)
        #systemctl --user restart streamutil@twitch.sh.service
        systemctl --user stop streamutil@genpng.sh.service
        systemctl --user stop streamutil@savepi.sh.service
        ;;
    online)
        systemctl --user restart streamutil@savepi.sh.service
        systemctl --user restart streamutil@genpng.sh.service
        #systemctl --user restart streamutil@twitch.sh.service
        ;;
    esac
done < <(mosquitto_sub -h homeassistant.local -t local/birdfeeder/status)

