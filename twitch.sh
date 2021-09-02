
set -x

source common.sh

[ -n "$ASSERVICE" ] && sleep 20

ttoken=$(<.ttoken)
#ytoken=$(<.ytoken)
ffmpeg -y -hide_banner $ffopts \
    -thread_queue_size $tqs -probesize 64M -r 50 -f mpegts -i "udp://127.0.0.1:3334&fifo_size=500000000" \
    -f image2 -re -r 50 -stream_loop -1 -i overlay.png \
    -f jack -thread_queue_size $tqs -ac 1 -itsoffset 5 -i ffmpeg_twitch \
    -filter_complex '[0:v][1:v] overlay=10:10[o]' \
    -map '[o]' -map 2:a \
    -c:v libx264 -strict experimental -threads 4 -pix_fmt yuv420p -b:v 4500k -preset ultrafast -tune zerolatency \
    -c:a aac -q:a 1 -ar 48000 \
    -f flv "rtmp://live.twitch.tv/app/$ttoken"

#    -f flv /dev/null
#    -f mpegts udp://127.0.0.1:3330

