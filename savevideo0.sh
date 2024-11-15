#!/bin/bash

set -vx

fifo=/run/user/$UID/ffmpeg.fifo
mkfifo $fifo
mpid=/run/user/$UID/ffmpeg.pid

rot=90

function stop {
    pgrep ffmpeg | grep $(cat $mpid) || return
    echo q >$fifo &
    sleep 1
    cat $fifo &
    sleep 2
    killall echo
    killall cat
    #killall ffmpeg
}

trap "stop" EXIT SIGINT


stop

if [ -z "$rot" ]; then
    v4l2-ctl --set-ctrl rotate=0
    vs=1280x720
    v4l2-ctl -v width=1280,height=720,pixelformat=H264
    #vs=1920x1080
else
    v4l2-ctl --set-ctrl rotate=$rot
    vs=720x1280
    v4l2-ctl -v width=720,height=1280,pixelformat=H264
    #vs=1080x1920
fi

v4l2-ctl -p 60
v4l2-ctl --set-ctrl video_bitrate=25000000
#v4l2-ctl --set-ctrl repeat_sequence_header=1
# this qp lower is better
v4l2-ctl --set-ctrl h264_minimum_qp_value=1
v4l2-ctl --set-ctrl h264_maximum_qp_value=10
v4l2-ctl --set-ctrl h264_i_frame_period=10
v4l2-ctl --set-ctrl h264_level=13
#v4l2-ctl --set-ctrl exposure_time_absolute=20
v4l2-ctl --set-ctrl exposure_time_absolute=20
v4l2-ctl --set-ctrl auto_exposure=1
v4l2-ctl --set-ctrl auto_exposure_bias=13
v4l2-ctl --set-ctrl iso_sensitivity=4
v4l2-ctl --set-ctrl iso_sensitivity_auto=0
v4l2-ctl --set-ctrl exposure_metering_mode=3
cat $fifo | \
    ffmpeg -hide_banner -stdin -loglevel info \
        -fflags +discardcorrupt+genpts \
        -f video4linux2 -input_format h264 -video_size $vs -i /dev/video0 \
        -fflags +discardcorrupt+genpts \
        -r 60 \
        -vcodec copy -an \
        /mnt/birds/$(date +%F_%R).mkv &

echo $! >$mpid
waitpid $!


#Nov 14 11:57:41 alarmpi4 streamutil@savevideo0.sh[1313]: [mp4 @ 0x24ae8a0] Timestamps are unset in a packet for stream 0. This is deprecated and will stop working in the future. Fix your code to set the timestamps properly
#Nov 14 11:57:41 alarmpi4 streamutil@savevideo0.sh[1313]: [vost#0:0/copy @ 0x24e7180] Non-monotonic DTS; previous: 0, current: 0; changing to 1. This may result in incorrect timestamps in the output file.

# -bsf:v dts2pts
# -bsf:v setts=pts=STARTPTS+N/TB_OUT/50
#        -fflags +genpts+igndts -use_wallclock_as_timestamps 1 -r 50 \
#        -r 50 -enc_time_base 0 -itsoffset 1 \
#        -fflags +genpts+igndts -use_wallclock_as_timestamps 1 \
#        -enc_time_base 0 \
#        -fflags +genpts+igndts \
#
# $ v4l2-ctl -l 
# 
# User Controls
# 
#                      brightness 0x00980900 (int)    : min=0 max=100 step=1 default=50 value=50 flags=slider
#                        contrast 0x00980901 (int)    : min=-100 max=100 step=1 default=0 value=0 flags=slider
#                      saturation 0x00980902 (int)    : min=-100 max=100 step=1 default=0 value=0 flags=slider
#                     red_balance 0x0098090e (int)    : min=1 max=7999 step=1 default=1000 value=1000 flags=slider
#                    blue_balance 0x0098090f (int)    : min=1 max=7999 step=1 default=1000 value=1000 flags=slider
#                 horizontal_flip 0x00980914 (bool)   : default=0 value=0
#                   vertical_flip 0x00980915 (bool)   : default=0 value=0
#            power_line_frequency 0x00980918 (menu)   : min=0 max=3 default=1 value=1 (50 Hz)
#                       sharpness 0x0098091b (int)    : min=-100 max=100 step=1 default=0 value=0 flags=slider
#                   color_effects 0x0098091f (menu)   : min=0 max=15 default=0 value=0 (None)
#                          rotate 0x00980922 (int)    : min=0 max=360 step=90 default=0 value=0 flags=modify-layout
#              color_effects_cbcr 0x0098092a (int)    : min=0 max=65535 step=1 default=32896 value=32896
# 
# Codec Controls
# 
#              video_bitrate_mode 0x009909ce (menu)   : min=0 max=1 default=0 value=0 (Variable Bitrate) flags=update
#                   video_bitrate 0x009909cf (int)    : min=25000 max=25000000 step=25000 default=10000000 value=25000000
#          repeat_sequence_header 0x009909e2 (bool)   : default=0 value=0
#                 force_key_frame 0x009909e5 (button) : value=0 flags=write-only, execute-on-write
#           h264_minimum_qp_value 0x00990a61 (int)    : min=0 max=51 step=1 default=0 value=0
#           h264_maximum_qp_value 0x00990a62 (int)    : min=0 max=51 step=1 default=0 value=0
#             h264_i_frame_period 0x00990a66 (int)    : min=0 max=2147483647 step=1 default=60 value=60
#                      h264_level 0x00990a67 (menu)   : min=0 max=13 default=11 value=11 (4)
#                    h264_profile 0x00990a6b (menu)   : min=0 max=4 default=4 value=4 (High)
# 
# Camera Controls
# 
#                   auto_exposure 0x009a0901 (menu)   : min=0 max=3 default=0 value=0 (Auto Mode)
#          exposure_time_absolute 0x009a0902 (int)    : min=1 max=10000 step=1 default=1000 value=1000
#      exposure_dynamic_framerate 0x009a0903 (bool)   : default=0 value=0
#              auto_exposure_bias 0x009a0913 (intmenu): min=0 max=24 default=12 value=12 (0 0x0)
#       white_balance_auto_preset 0x009a0914 (menu)   : min=0 max=10 default=1 value=1 (Auto)
#             image_stabilization 0x009a0916 (bool)   : default=0 value=0
#                 iso_sensitivity 0x009a0917 (intmenu): min=0 max=4 default=0 value=0 (0 0x0)
#            iso_sensitivity_auto 0x009a0918 (menu)   : min=0 max=1 default=1 value=1 (Auto)
#          exposure_metering_mode 0x009a0919 (menu)   : min=0 max=3 default=0 value=0 (Average)
#                      scene_mode 0x009a091a (menu)   : min=0 max=13 default=0 value=0 (None)
# 
# JPEG Compression Controls
# 
#             compression_quality 0x009d0903 (int)    : min=1 max=100 step=1 default=30 value=30
# 
#
#
#Camera Controls
#
#                  auto_exposure 0x009a0901 (menu)   : min=0 max=3 default=0 value=0 (Auto Mode)
#                                0: Auto Mode
#                                1: Manual Mode
#         exposure_time_absolute 0x009a0902 (int)    : min=1 max=10000 step=1 default=1000 value=1000
#     exposure_dynamic_framerate 0x009a0903 (bool)   : default=0 value=0
#             auto_exposure_bias 0x009a0913 (intmenu): min=0 max=24 default=12 value=12 (0 0x0)
#                                0: -4000 (0xfffffffffffff060)
#                                1: -3667 (0xfffffffffffff1ad)
#                                2: -3333 (0xfffffffffffff2fb)
#                                3: -3000 (0xfffffffffffff448)
#                                4: -2667 (0xfffffffffffff595)
#                                5: -2333 (0xfffffffffffff6e3)
#                                6: -2000 (0xfffffffffffff830)
#                                7: -1667 (0xfffffffffffff97d)
#                                8: -1333 (0xfffffffffffffacb)
#                                9: -1000 (0xfffffffffffffc18)
#                                10: -667 (0xfffffffffffffd65)
#                                11: -333 (0xfffffffffffffeb3)
#                                12: 0 (0x0)
#                                13: 333 (0x14d)
#                                14: 667 (0x29b)
#                                15: 1000 (0x3e8)
#                                16: 1333 (0x535)
#                                17: 1667 (0x683)
#                                18: 2000 (0x7d0)
#                                19: 2333 (0x91d)
#                                20: 2667 (0xa6b)
#                                21: 3000 (0xbb8)
#                                22: 3333 (0xd05)
#                                23: 3667 (0xe53)
#                                24: 4000 (0xfa0)
#      white_balance_auto_preset 0x009a0914 (menu)   : min=0 max=10 default=1 value=1 (Auto)
#                                0: Manual
#                                1: Auto
#                                2: Incandescent
#                                3: Fluorescent
#                                4: Fluorescent H
#                                5: Horizon
#                                6: Daylight
#                                7: Flash
#                                8: Cloudy
#                                9: Shade
#                                10: Greyworld
#            image_stabilization 0x009a0916 (bool)   : default=0 value=0
#                iso_sensitivity 0x009a0917 (intmenu): min=0 max=4 default=0 value=0 (0 0x0)
#                                0: 0 (0x0)
#                                1: 100000 (0x186a0)
#                                2: 200000 (0x30d40)
#                                3: 400000 (0x61a80)
#                                4: 800000 (0xc3500)
#           iso_sensitivity_auto 0x009a0918 (menu)   : min=0 max=1 default=1 value=1 (Auto)
#                                0: Manual
#                                1: Auto
#         exposure_metering_mode 0x009a0919 (menu)   : min=0 max=3 default=0 value=0 (Average)
#                                0: Average
#                                1: Center Weighted
#                                2: Spot
#                                3: Matrix
#                     scene_mode 0x009a091a (menu)   : min=0 max=13 default=0 value=0 (None)
#                                0: None
#                                8: Night
#                                11: Sports
#