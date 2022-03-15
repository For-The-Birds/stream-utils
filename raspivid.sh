#!/bin/bash

set -evx

function get_n {
    v=$(curl -s -X GET -H "Authorization: Bearer $(<.ha.token)" -H "Content-Type: application/json" http://homeassistant:8123/api/states/input_number.$1)

    v=$( echo "$v" | jq '.state' | tr -d '"' )
    v=$(printf '%.0f' "$v")
    echo $v
}

/opt/vc/bin/raspivid \
    -v -n -t 0 -w 1280 -h 720 \
    -fps 50 -g 10 -b $(( 2 << 23 )) \
    --ISO $(get_n iso) -ev $(get_n ev) -ex fixedfps --metering backlit \
    -drc low \
    -ih -stm \
    -a 4 -a 8 -a "%Y.%m.%d %H:%M:%S" -ae 8,bbbbbb,ffffff \
    -l -o tcp://0.0.0.0:3333/

