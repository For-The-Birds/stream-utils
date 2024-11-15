while read f ; do
    json=nestbox/$(basename "$f").json
    [ -s $json ] && continue
    ./darknet detector demo -dont_show \
        -out_filename $json \
        data/obj.data \
        cfg/yolov4-tiny-custom-3.cfg \
        backup/yolov4-tiny-custom-3_final.weights $f
done
