
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -probesize 32M -thread_queue_size 4096 -analyzeduration 50000000 -r 15 -i udp://localhost:3322 \
    -f jack -thread_queue_size 4096 -ac 1 -i ffmpeg_pi2 \
    -map 0:v -c:v copy -map 1:a -c:a libopus /mnt/birds/nestbox/$(date +%F_%R).mkv
