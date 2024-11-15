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

#fps=50

bn=$(basename "$1")
bn=${bn%%.???}
o=${2:-"$bn"}
mkdir -p "$o"

# cat file | cut -f1 | bash autocut.sh video.mkv

make_ranges 12 | \
while read start end; do
    [ -z "$start" ] && [ -z "$end" ] && continue
    #[ -z "$start" ] && continue
    echo "$start - $end   delta = "$(bc -l <<< "$end - $start")
    (( `bc -ql <<< "$end - $start < 1"` )) && continue
    #continue
    at=$(date -u -d @$start +"%T").0
    ffmpeg -hide_banner -nostdin -loglevel warning -y \
        -ss $(bc -l <<< "$start-2") \
        -to $(bc -l <<< "$end+4") \
        -i "$1" \
        -c:v copy -c:a copy "./$o/$bn-at-$at.mp4"
done
