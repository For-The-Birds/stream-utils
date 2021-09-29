darknet/darknet detector demo \
    -dont_show -out_filename $(basename "$1").json \
    darknet/data/obj.data \
    darknet/cfg/yolov4-tiny-custom.cfg \
    darknet/backup/yolov4-tiny-custom_final.weights \
    "$1"

#bash autocut.sh $(basename "$1").json "$1"
