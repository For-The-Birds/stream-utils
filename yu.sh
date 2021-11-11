
#set -xv
cd /mnt/birds/pivid

list=$(ls -1 ????-??-??_??:??.mp4 ????-??-??.mp4)
count=$(echo "$list" | wc -l)
c=0
#left=$(sort <(cat .yu.done) <(echo "$list") | uniq -u)
#left_count=$(echo "$left" | wc -l)

echo "$list" | while read f ; do
    (( c++ ))
    grep "$f" .yu.done >/dev/null && continue
    echo "$c/$count $f"
    d=$(echo "$f" | cut -f1 -d. | tr _ ' ')
    diso=$(date  -d "$d" -Iseconds)
    # yay -S youtube-upload
    ~/.local/bin/youtube-upload \
        --title="Birds $d" \
        -c 'Pets & Animals'\
        --tags birds,birdfeeder \
        --privacy=public \
        --license=creativeCommon \
        --location=latitude=55.61,longitude=37.57 \
        --recording-date=$diso \
        "$f" || break
    echo "$f" >>.yu.done
    sleep 1m
done

[[ $? == 0 ]] && echo "all $count done"

#sleep 1h
