
set -x

source common.sh

[ -n "$ASSERVICE" ] && sleep 5

ttoken=$(<.ttoken)
#ytoken=$(<.ytoken)
ffmpeg -y -hide_banner $ffopts \
    -thread_queue_size $tqs -probesize 64M -r 50 -f mpegts -i "udp://127.0.0.1:3334&fifo_size=500000000" \
    -f image2 -re -r 50 -stream_loop -1 -i overlay.png \
    -f jack -thread_queue_size $tqs -ac 1 -itsoffset 6 -i ffmpeg_twitch \
    -filter_complex '[0:v][1:v] overlay=10:H-h-10[o]' \
    -map '[o]' -map 2:a \
    -c:v h264_nvenc -preset llhq -profile:v high -coder cabac -rc-lookahead 8 -spatial_aq 1 -pix_fmt yuv420p -b:v 4500k \
    -c:a aac -q:a 1 -ar 48000 \
    -f flv "rtmp://live.twitch.tv/app/$ttoken"

#-c:v h264_nvenc -preset p7 -profile:v high -coder cabac -rc-lookahead 32 -spatial_aq 1
#-c:v libx264 -strict experimental -threads 4 -pix_fmt yuv420p -b:v 4500k -preset ultrafast -tune zerolatency \

#    -f flv /dev/null
#    -f mpegts udp://127.0.0.1:3330

