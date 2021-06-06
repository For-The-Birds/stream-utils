
set -x

ttoken=$(<.ttoken)
#ytoken=$(<.ytoken)
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -fflags +discardcorrupt -thread_queue_size 4096 -probesize 64M -r 50 -f mpegts -i "udp://127.0.0.1:33333&fifo_size=500000000" \
    -f image2 -re -r 50 -stream_loop -1 -i overlay.png \
    -f jack -thread_queue_size 2048 -ac 1 -i ffmpeg_twitch \
    -filter_complex '[0:v][1:v] overlay=10:10[o]' \
    -map '[o]' \
    -c:v libx264 -g 100 -strict experimental -threads 4 -pix_fmt yuv420p -b:v 4500k -preset fast -tune zerolatency \
    -map 2:a -c:a aac -q:a 1 -ar 48000 -movflags +faststart \
    -f flv "rtmp://live.twitch.tv/app/$ttoken"

#    -f mpegts udp://127.0.0.1:3330

