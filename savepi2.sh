
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -i udp://localhost:3322 \
    -map 0 -c copy /mnt/birds/nestbox/$(date +%F_%R).mkv \
    -map 0:0 -c copy -f mpegts udp://127.0.0.1:3332/
