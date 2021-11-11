o="$1"
o=${o:=/mnt/birds/audio/$(<.date).opus}

ffmpeg -y -hide_banner -nostdin -loglevel info \
    -f jack -ac 1 -i ffmpeg_bird_audio_dump \
    -c:a libopus \
    $o

# -af adelay=5000
