###!/bin/bash

# readlink gives absolute path
export sdir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

[ -z "$sdir" ] && exit

#source $sdir/.personal.sh

_apicall() {
    read token <$sdir/.token${_token:-}


    s="--silent"
    s=
    curl $s \
        -X POST http://farm.lan:8081/bot$token/$1 \
        "${@:2}"
}

apicall() {
    APILOG=${APILOG:-apicall.log}
    #_apicall "$@"
    #_apicall "$@" | tee -a apicall.log
    #_apicall "$@" > "$APILOG"
    _apicall "$@" | tee -a "$APILOG" | jq
    cat "$APILOG" | jq -e '.ok == true' >/dev/null || ( cat "$APILOG" | jq )
}

sendAudio() {
    apicall \
        sendAudio \
        -F chat_id="$1" \
        -F caption="${@:3}" \
        -F audio=@$2
}

sendMessage() {
    apicall \
        sendMessage \
        -F parse_mode=MarkdownV2 \
        -F chat_id="$1" \
        -F text="${@:2}"
}

sendPhoto() {
    apicall \
        sendPhoto \
        -F chat_id="$1" \
        -F caption="${@:3}" \
        -F photo=@$2
}

ffjson() {
    ffprobe -v quiet -print_format json -show_format -show_streams "$1"
}

sendVideo() {
    o=$2
    [ -s "$o" ] || return -1

    dur=$(ffjson "$o" | jq -r '.streams[0].duration')
    dur=$(printf %.0f $dur)

    apicall \
        sendVideo \
        -F chat_id="$1" \
        -F caption="${@:3}" \
        -F video=@"$o" \
        -F duration=$dur
}

function tgmono {
    echo -e "\x60${@}\x60"
}

function tglog {
    m=$(tgmono "${@:2}")
    sendMessage $1 "$m"
}


