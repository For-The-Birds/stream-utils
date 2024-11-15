
source common.sh

ffmpeg -y -hide_banner -nostdin -loglevel info \
    -fflags +discardcorrupt+genpts \
    -r 50 -i tcp://alarmpi4.lan:3333 -fps_mode 0 \
    -c:v copy -bsf:v dts2pts -r 50 \
    /mnt/birds/pivid/$(date +%F_%R).mkv \
    -map 0:0 -r 50 -fps_mode 0 \
    -c:v copy -bsf:v dts2pts \
    -f mpegts udp://127.0.0.1:3333/

exit

ffmpeg -y -hide_banner -nostdin -loglevel warning \
    -probesize 32M -thread_queue_size 131072 \
    -r 50 -i tcp://alarmpi4.lan:3333 \
    -f jack -thread_queue_size 131072 -channels 1 -i ffmpeg_birds \
    -map 0:0 -map 1:0 -r 50 -fps_mode 0 \
    -c:v copy -c:a libopus -b:a 128k \
    /mnt/birds/pivid/$(date +%F_%R).mkv \
    -map 0:0 -r 50 -fps_mode 0 -c:v copy -f mpegts udp://127.0.0.1:3333/


exit

ffmpeg -y -hide_banner $ffopts -fflags +genpts+igndts -use_wallclock_as_timestamps 1 \
    -probesize 32M -thread_queue_size $tqs -i tcp://alarmpi4.lan:3333 \
    -f jack -thread_queue_size $tqs -ac 1 -itsoffset 1 -i ffmpeg_birds \
    -map 0:0 -map 1:0 \
        -r 50 -vsync 1 \
        -c:v copy -c:a libopus -b:a 128k \
        /mnt/birds/pivid/$(date +%F_%R).mkv \
    -map 0:0 \
        -r 50 -vsync 1 \
        -c:v copy \
        -f mpegts udp://127.0.0.1:3333/ \
    -map 0:0 \
        -r 50 -vsync 1 \
        -c:v copy \
        -f mpegts udp://127.0.0.1:3334/


exit

#    -f image2 -r 50 -re -stream_loop -1 -i overlay.png \
#    -f jack -thread_queue_size $tqs -ac 1 -itsoffset 5 -i ffmpeg_twitch \
#    -filter_complex '[0:v][2:v] overlay=10:10[o]' \
#    -map '[o]' -map 3:a \
#        -c:v libx264 -g 100 -strict experimental -threads 4 -pix_fmt yuv420p -b:v 4500k -preset fast -tune zerolatency \
#        -c:a aac -q:a 1 \
#        -f flv /dev/null \


#    -f image2 -re -stream_loop -1 -i overlay.png \
#    -f jack -thread_queue_size $tqs -ac 1 -i ffmpeg_twitch \
#    -filter_complex '[0:v][2:v] overlay=10:10[o]' \
#
#    -map '[o]' -map 3:a \
#        -c:v libx264 -g 100 -strict experimental -threads 4 -pix_fmt yuv420p -b:v 4500k -preset fast -tune zerolatency \
#        -c:a aac -q:a 1 -af adelay=5000 -movflags +faststart \
#        -f flv /dev/null
##        -vsync 0 -use_wallclock_as_timestamps 1 -f flv "rtmp://live.twitch.tv/app/$(<.ttoken)"


# -filter_complex "[0:v]setpts=PTS-STARTPTS[birds];[2:v]setpts=PTS-STARTPTS[overlay];[birds][overlay]overlay=10:10[o];" \

# ffmpeg.exe -f dshow -use_wallclock_as_timestamps 1
# -i audio="WNIP Input  1 (Wheatstone Network Audio (WDM))"
# -itsoffset 2.1 -f decklink -thread_queue_size 128  -use_wallclock_as_timestamps 1
# -i "DeckLink SDI (3)" -filter_complex "[1:v:0]bwdif,format=yuv420p,setdar=16/9,scale=-1:576:flags=bicubic[vidout];[0:a:0]aresample=min_comp=0.02:comp_duration=15:max_soft_comp=0.005[audioout]"
# -c:v libx264 -preset slow -crf 25 -maxrate 1200k -bufsize 2400k
# -map "[vidout]:0" -map "[audioout]:0" -vsync 1 -r 50 -g 90 -keyint_min 90 -sc_threshold 0
# -c:a libfdk_aac -b:a 192k -ac 2 -f flv "rtmp://somewhere"

# -af aresample=async=1
# -use_wallclock_as_timestamps 1
# -vsync 0 -enc_time_base -1 \
