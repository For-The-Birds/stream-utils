
source common.sh

ffmpeg -y -hide_banner $ffopts -fflags +genpts+igndts -use_wallclock_as_timestamps 1 \
    -probesize 32M -thread_queue_size $tqs -i tcp://alarmpi2.lan:3333 \
    -f jack -thread_queue_size $tqs -ac 1 -itsoffset 1 -i ffmpeg_birds2 \
    \
    -map 0:0 -map 1:0 \
        -vsync 1 \
        -c:v copy -c:a libopus -b:a 128k \
        /mnt/birds/nestbox/$(date +%F_%R).mkv \
    -map 0:0 \
        -vsync 1 \
        -c:v copy \
        -f mpegts udp://127.0.0.1:3332/ \
    -map 0:0 \
        -vsync 1 \
        -c:v copy \
        -f mpegts udp://127.0.0.1:3331/


exit



ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -probesize 32M -thread_queue_size 4096 -analyzeduration 50000000 -r 15 -i udp://localhost:3322 \
    -f jack -thread_queue_size 4096 -ac 1 -i ffmpeg_pi2 \
    -map 0:v -c:v copy -map 1:a -c:a libopus /mnt/birds/nestbox/$(date +%F_%R).mkv
