set -uv

lx() {
    printf "%.2f" $(curl -s livingroom.local/sensor/livingroom_illuminance | jq '.value') || true
}

seconds_file_modified() {
    bc <<< "$(date +%s) - $(stat -c %Y $1)"
}

donations() {
    token=$(cat .token.json | jq '.access_token' | tr -d \")

    curl -s --max-time 4 -X GET https://www.donationalerts.com/api/v1/alerts/donations \
        -H "Authorization: Bearer $token"
}

donations_format() {
    d=$(donations)
    (( $? )) && return 1
    username=$(jq '.data[0].username' <<< $d | tr -d \")
    message=$(jq '.data[0].message' <<< $d)
    amount=$(jq '.data[0].amount' <<< $d)
    currency=$(jq '.data[0].currency' <<< $d | tr -d \")

    echo "$message"
    echo
    echo "$username, $amount $currency"
}

while true; do
    t=$(curl -s livingroom.local/sensor/outside | jq '.state' | tr -d '"')
    label="$(date '+%F %R')  $t  $(lx) lux"
    echo -e "\n$label"
    gm convert -background none -font /usr/share/fonts/liberation/LiberationSerif-Regular.ttf \
        -pointsize 32 -fill 'rgba(64,64,64,100)' \
        label:"$label" info.png

    #echo $(donations | jq '.data[] | (.username, .amount)')
    d=$(donations_format)
    (( $? )) || echo "$d" > donations_text
    if ! diff -q donations_text donations_text.old; then
        gm convert -size 300x400 -background transparent -fill 'rgba(64,128,64,100)' \
            -font /usr/share/fonts/liberation/LiberationSerif-Regular.ttf \
            -pointsize 24 caption:"$d" donation.png
        mv donations_text donations_text.old
        echo "donation $(<donations_text.old)"
    fi
    if [ $(seconds_file_modified donations_text.old) -le 600 ] ; then
        gm montage info.png donation.png -background transparent -tile 1x2 -geometry +0+0 overlay_d.png
        mv overlay_d.png info.png
    fi

    mv info.png overlay.png

    sleep 10
done

