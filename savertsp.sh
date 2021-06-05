
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -i 'rtsp://chcam/user=admin&password=&channel=1&stream=0.sdp' \
    -f jack -thread_queue_size 4096 -ac 1 -i ffmpeg_nestbox \
    -c:v libx264 -pix_fmt yuv420p -crf 20 -preset fast -tune zerolatency \
    -map 0:0 -map 1:0 -c:v copy -c:a libopus /mnt/birds/chcam/$(date +%F_%R).mkv \
    -map 0:0 -c:v copy -f mpegts udp://127.0.0.1:3331/
