function make_ranges {
    threshold=$1

    read current
    start=$current
    prev=$current

    while read current; do
        #if [ $(( current - prev )) -gt $threshold ]; then
        if (( `bc -lq <<< "$current - $prev > $threshold"` )); then
            echo $start $prev
            start=$current
        fi
        prev=$current
    done
    echo $start $prev
}

fps=50

bn=$(basename "$1")
bn=${bn%%.???}
mkdir -p "$bn"

# cat file | cut -f1 | bash autocut.sh video.mkv

make_ranges 12 | \
while read start end; do
    #[ -z "$start" ] && continue
    echo "'$start' - '$end' " `bc -l <<< "$end - $start"`
    (( `bc -ql <<< "$end - $start < 2"` )) && continue
    #continue
    at=$(date -u -d @$start +"%T").0
    ffmpeg -hide_banner -nostdin -y \
        -ss $(bc -l <<< "$start-2") \
        -to $(bc -l <<< "$end+2") \
        -i "$1" \
        -c:v copy -c:a copy "$bn/$bn-at-$at.mp4"
done
