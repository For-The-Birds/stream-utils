ttoken=$(<.ttoken)
#ytoken=$(<.ytoken)

ffmpeg -hide_banner -nostdin -loglevel warning \
    -f jack -thread_queue_size 2048 -ac 1 -i ffmpeg_twitch \
    -probesize 32M -thread_queue_size 2048 -f mpegts -i udp://127.0.0.1:3331/ \
    -f image2 -re -stream_loop -1 -i overlay.png \
    -filter_complex "overlay=10:10" \
    -strict experimental -threads 4 -c:v libx264 -pix_fmt yuv420p -b:v 4500k -preset fast -tune zerolatency -g 100 \
    -c:a aac -q:a 1 -ar 48000 -movflags +faststart \
    -map 0:a -map 1:v \
    -f flv "rtmp://live.twitch.tv/app/$ttoken"

# tcp://alarmpi4.local:3333
