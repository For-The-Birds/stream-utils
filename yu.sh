
set -xv
cd /mnt/birds/pivid

ls -1 ????-??-??_??:??.mp4 | while read f ; do
    grep "$f" .yu.done && continue
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
    sleep 10m
done

sleep 1h
