bn=$(basename "$1")
mvs=$bn.mvs
[ -s "$mvs" ] || time ~/src/yekm/stream-utils/autocut/extract_mvs "$1" | pv -rab >"$mvs"

python mvs_mavg.py "$mvs"

fframes="$mvs-mean-filter.tsv"
sed "s/FILENAME/$mvs/" mvs.gnuplot | gnuplot -p
cat "$fframes" | \
	cut -f2 | \
	bash autocut.sh "$1"
