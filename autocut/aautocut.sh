#!/bin/bash

set -vx

SRCDIR=$(dirname $(readlink ${BASH_SOURCE[0]}))/
echo $SRCDIR

bn=$(basename "$1")
#bn=${bn%%.???}
mvs=mvs/$bn.mvs
mkdir -p mvs

echo $mvs: Extracting motion vertors from $1
[ -s "$mvs" ] || time $SRCDIR/extract_mvs "$1" | pv -rab >"$mvs"

echo $mvs: Computing moving averages and filtering
time python $SRCDIR/mvs_mavg.py "$mvs"

sed "s;FILENAME;$mvs;" $SRCDIR/mvs.gnuplot | gnuplot -p

pieces=${bn%%.???}
[ -d "$pieces" ] && echo "directory $pieces exists" && exit
mkdir -p "$pieces"

exit

cat "$mvs-mean-filter.tsv" | \
cut -f2 | \
bash $SRCDIR/make_ranges.sh 12 | \
while read start end; do
    #[ -z "$start" ] && continue
    echo "'$start' - '$end' " `bc -l <<< "$end - $start"`
    (( `bc -ql <<< "$end - $start < 2"` )) && continue
    #continue
	avg=$(cat "$mvs-mean-filter.tsv" | \
		sed -n "/$start/,/$end/ p" | \
		cut -f3 | \
		python $SRCDIR/avg.py | \
		cut -f1 -d.)
    at=$(date -u -d @$start +"%T").$avg
    ffmpeg -hide_banner -nostdin -loglevel warning -y \
        -ss $(bc -l <<< "$start-2") \
        -to $(bc -l <<< "$end+2") \
        -i "$1" \
        -c:v copy -c:a copy "$pieces/$bn.cut-at-$at.mp4"
done
