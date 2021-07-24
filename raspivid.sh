#!/bin/bash

set -evx

ev=$(curl -s -X GET -H "Authorization: Bearer $(<.ha.token)" -H "Content-Type: application/json" http://homeassistant:8123/api/states/input_number.ev)

ev=$( echo "$ev" | jq '.state' | tr -d '"' )
ev=$(printf '%.0f' "$ev")

/opt/vc/bin/raspivid \
    -v -n -t 0 -w 1280 -h 720 \
    -fps 49 -g 10 -b $(( 2 << 23 )) \
    --ISO 100 -ev $ev -ex fixedfps --metering backlit \
    -l -ih -stm -a 4 -a 8 -ae 8,bbbbbb,ffffff -drc low \
    -o tcp://0.0.0.0:3333/
