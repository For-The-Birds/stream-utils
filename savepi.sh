
ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -probesize 32M -thread_queue_size 4096 -i tcp://alarmpi4.local:3333 \
    -f jack -thread_queue_size 4096 -ac 1 -i ffmpeg_birds \
    -map 0:0 -map 1:0 -c:v copy -c:a libopus /mnt/birds/pivid/$(date +%F_%R).mkv \
    -map 0:0 -c:v copy -f mpegts udp://127.0.0.1:3333/ \
    -map 0:0 -c:v copy -f mpegts udp://127.0.0.1:33333/


# ffmpeg.exe -f dshow -use_wallclock_as_timestamps 1
# -i audio="WNIP Input  1 (Wheatstone Network Audio (WDM))"
# -itsoffset 2.1 -f decklink -thread_queue_size 128  -use_wallclock_as_timestamps 1
# -i "DeckLink SDI (3)" -filter_complex "[1:v:0]bwdif,format=yuv420p,setdar=16/9,scale=-1:576:flags=bicubic[vidout];[0:a:0]aresample=min_comp=0.02:comp_duration=15:max_soft_comp=0.005[audioout]"
# -c:v libx264 -preset slow -crf 25 -maxrate 1200k -bufsize 2400k
# -map "[vidout]:0" -map "[audioout]:0" -vsync 1 -r 50 -g 90 -keyint_min 90 -sc_threshold 0
# -c:a libfdk_aac -b:a 192k -ac 2 -f flv "rtmp://somewhere"

# -af aresample=async=1
# -use_wallclock_as_timestamps 1
