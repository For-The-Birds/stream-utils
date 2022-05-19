#for day in $(ls -1 *-at-*.mp4 | cut -f1 -d_ | sort | uniq -d); do
for day in $(ls -1 2022-*_*.mp4 | cut -f1 -d_ | sort | uniq -d); do
    bash catday.sh $day
done
