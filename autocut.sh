function make_ranges {
    threshold=$1

    read current
    start=$current
    prev=$current

    while read current; do
        if [ $(( current - prev )) -gt $threshold ]; then
            echo $start $prev
            start=$current
        fi
        prev=$current
    done
    echo $start $prev
}

fps=50

bn=$(basename "$2")
bn=${bn%%.???}
mkdir "$bn"

cat "$1" | \
    jq '.[] | select(.objects[0].confidence > 0.82) | .frame_id' | \
    make_ranges 100 | \
    while read start end; do
        ffmpeg -hide_banner -nostdin -y \
            -ss $(bc -l <<< "$start/$fps-3") \
            -to $(bc -l <<< "$end/$fps+0.5") \
            -i "$2" \
            -c:v copy -c:a copy "$bn/$start-$end.mp4"
    done
