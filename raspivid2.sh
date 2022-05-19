#!/bin/bash

set -evx

function get_n {
    v=$(curl -s -X GET -H "Authorization: Bearer $(<.ha.token)" -H "Content-Type: application/json" http://homeassistant:8123/api/states/input_number.$1)

    v=$( echo "$v" | jq '.state' | tr -d '"' )
    v=$(printf '%.0f' "$v")
    echo $v
}

/opt/vc/bin/raspivid \
    -v -n -t 0 -md 1 \
    -fps 30 -g 10 -b $(( 1 << 24 )) \
    --ISO $(get_n iso2) -ev $(get_n ev2) -ex fixedfps --metering backlit \
    -drc low \
    -ih -stm \
    -a 4 -a 8 -a "%Y.%m.%d %H:%M:%S" -ae 16,bbbbbb,ffffff \
    -l -o tcp://0.0.0.0:3333/

