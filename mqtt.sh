#!/bin/bash

#[ "$(<.status)" = "online" ] && systemctl --user restart streamutil@savepi.sh.service

while read msg; do
    echo "$msg" #| tee .status
    case "$msg" in
    offline)
        #systemctl --user restart streamutil@twitch.sh.service
        #systemctl --user stop streamutil@genpng.sh.service
        systemctl --user stop streamutil@savepi.sh.service
        #systemctl --user stop streamutil@savepi2.sh.service

        #systemctl --user stop streamutil@savertsp.sh.service
        systemctl --user restart streamutil@yu.sh.service
        ;;
    online)
        systemctl --user restart streamutil@savepi.sh.service
        #systemctl --user restart streamutil@savepi2.sh.service
        #systemctl --user restart streamutil@genpng.sh.service
        #systemctl --user restart streamutil@twitch.sh.service

        #systemctl --user restart streamutil@savertsp.sh.service
        systemctl --user stop streamutil@yu.sh.service
        ;;
    esac
done < <(mosquitto_sub -h homeassistant.local -t local/birdfeeder/status)

