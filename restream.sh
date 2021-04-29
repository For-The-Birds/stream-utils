#ffmpeg -f jack -thread_queue_size 2048 -ac 1 -i birdvid -c:a aac \
ffmpeg \
    -probesize 32M -thread_queue_size 2048 -i tcp://alarmpi4.local:3333 \
    -map 0:0 -c copy /mnt/0/bak/pi4vid/pi4_$(date +%F_%R).mkv \
    -map 0:0 -c:v libx264 -preset veryfast -tune zerolatency -crf 14 -b:v 4500k -g 100 \
    -f mpegts udp://acer.local:1935/birdvid

#-f fifo -fifo_format flv \
#    -drop_pkts_on_overflow 1 -attempt_recovery 1 -recover_any_error 1 \
#    rtmp://acer.local:1935/birdvid
    #-f flv -listen 1 rtmp://0.0.0.0:1935/birdvid
    #-f tee -map 0 \
    #"/home/yekm/birds/pi4_$(date +%F_%R).mkv|[f=flv:onfail=ignore]rtmp://0.0.0.0:1935/birdvid listen=1"
