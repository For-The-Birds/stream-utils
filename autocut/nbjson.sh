
acat () {
    zcat $1 || cat $1
}

parallel -n1 bash $SRCDIR/autocut/json-filter.sh ::: *.mkv.json.gz

for json in $@; do
    #tsv="$json.tsv"
    #sf=$tsv.starling_frames
    bn=$(basename $json)
    video=/mnt/birds/nestbox/${bn%%.json*}
    fps=$(ffjson.sh $video | jq -r '.streams[0].r_frame_rate')
    #grep -v 0$ $tsv | cut -f1 | sed "s,$,/$fps," | bc -l | bash autocut.sh $video starling

    fjson=$json.filtered.json.gz

    acat $fjson | jq -r '.[] | select(.l_starling> 0).frame' | \
        sed "s,$,/$fps," | bc -l | bash autocut.sh $video starling
    acat $fjson | jq -r '.[] | select(.l_bird > 1).frame' | \
        sed "s,$,/$fps," | bc -l | bash autocut.sh $video twobirds
done
