ttoken=$(<.ttoken)
ytoken=$(<.ytoken)
f="f=fifo:fifo_format=flv:drop_pkts_on_overflow=1:attempt_recovery=1:recovery_wait_time=1"

trap "pkill -s 0 -F .ffmpeg.pid ffmpeg; exit" SIGINT SIGTERM EXIT

while true; do
    sleep 1
    pgrep -F .ffmpeg.pid ffmpeg >/dev/null && continue
    [ "$(<.status)" = "offline" ] && continue
    ffmpeg -f jack -thread_queue_size 2048 -ac 1 -i ffmpeg -c:a aac \
        -probesize 32M -thread_queue_size 2048 -i tcp://alarmpi4.local:3333 \
        -f image2 -re -stream_loop -1 -i overlay.png \
        -filter_complex "overlay=10:10" \
        -g 100 \
        -strict experimental -threads 4 -c:v libx264 -map 0:a -map 1:v -b:v 4500k -preset ultrafast \
        -c:a aac -q:a 1 -ar 48000 -movflags +faststart \
        -f flv "rtmp://live.twitch.tv/app/$ttoken" \
        &
        #-probesize 32M -thread_queue_size 2048 -f mpegts -i udp://acer.local:1935/birdvid \
        #-r 50 -probesize 64M -thread_queue_size 4096 -re -f mpegts -i udp://acer.local:1935/birdvid \
        #-r 50 -probesize 32M -thread_queue_size 2048 -i tcp://h0me.local:1935 \
        #-drop_pkts_on_overflow 1 -attempt_recovery 1 -recover_any_error 1 \
        #-f tee "[$f]rtmp://live.twitch.tv/app/$ttoken" \
        #-f tee "[$f]rtmp://a.rtmp.youtube.com/live2/$ytoken|[$f]rtmp://live.twitch.tv/app/$ttoken" \
        #-f fifo -fifo_format flv \
        #"rtmp://live.twitch.tv/app/$ttoken" \
        #&
    echo $! >.ffmpeg.pid
    sleep 3
    #jack_connect zita-n2j:out_1 ffmpeg:input_1
    jack_connect gate_recorder:output0 ffmpeg:input_1
    jack_connect zita-n2j:out_1 gate_recorder:input0
done

