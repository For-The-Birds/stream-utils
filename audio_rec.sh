ffmpeg -y -hide_banner -nostdin -loglevel info \
    -f jack -ac 1 -i ffmpeg_birds \
    -c:a libopus \
    /mnt/birds/audio/$(<.date).opus

# -af adelay=5000