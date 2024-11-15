set -xv

dndir=/home/yekm/src/repos/darknet

nn=yolov4-tiny-custom
nn=yolov4

d=data/obj.data
d=cfg/coco.data

time $dndir/darknet detector demo \
    -dont_show -out_filename $(basename "$1").json \
    $dndir/$d \
    $dndir/cfg/$nn.cfg \
    $dndir/backup/${nn}_final.weights \
    "$1"

exit



#bash autocut.sh $(basename "$1").json "$1"
