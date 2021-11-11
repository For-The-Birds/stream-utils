set -xv

dndir=/home/yekm/src/repos/darknet

$dndir/darknet detector demo \
    -dont_show -out_filename $(basename "$1").json \
    $dndir/data/obj.data \
    $dndir/cfg/yolov4-tiny-custom.cfg \
    $dndir/backup/yolov4-tiny-custom_final.weights \
    "$1"

#bash autocut.sh $(basename "$1").json "$1"
