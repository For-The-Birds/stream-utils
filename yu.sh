
#set -xv
cd /mnt/birds/pivid

#list=$(ls -1 ????-??-??_??:??.mp4 ????-??-??.mp4)
list=$(ls -1 2024-??-??.mp4 | sort)
count=$(echo "$list" | wc -l)
c=0
#left=$(sort <(cat .yu.done) <(echo "$list") | uniq -u)
#left_count=$(echo "$left" | wc -l)

echo "$list" | while read f ; do
    (( c++ ))
    echo "$c/$count $f"
    grep "$f" .yu.done >/dev/null && continue
    d=$(echo "$f" | cut -f1 -d. | tr _ ' ')
    diso=$(date  -d "$d" -Iseconds)
    # yay -S youtube-upload
    youtube-upload \
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

[[ $? == 0 ]] && echo "$c/$count done"

#sleep 1h
