
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -r 50 -probesize 32M -thread_queue_size 4096 -i tcp://alarmpi4.local:3333 \
    -f jack -thread_queue_size 4096 -ac 1 -i ffmpeg_birds \
    -map 0:0 -map 1:0 -c:v copy -c:a libopus /mnt/birds/pivid/$(date +%F_%R).mkv \
    -map 0:0 -c:v copy -f mpegts udp://127.0.0.1:3333/
