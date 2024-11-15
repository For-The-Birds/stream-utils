set -uv

function get_state {
    curl -s -X GET \
        -H "Authorization: Bearer $(<.ha.token)" \
        -H "Content-Type: application/json" \
        http://homeassistant.lan:8123/api/states/input_number.$1 | \
    jq -r '.state'
}

lx() {
    printf "%.2f" $(curl -s livingroom.lan/sensor/livingroom_illuminance | jq '.value') || true
}

seconds_file_modified() {
    bc <<< "$(date +%s) - $(stat -c %Y $1)"
}

donations() {
    token=$(cat .token.json | jq -r '.access_token')

    curl -s --max-time 4 -X GET https://www.donationalerts.com/api/v1/alerts/donations \
        -H "Authorization: Bearer $token"
}

donations_format() {
    d=$(donations)
    (( $? )) && return 1
    username=$(jq -r '.data[0].username' <<< $d)
    message=$(jq -r '.data[0].message' <<< $d)
    amount=$(jq -r '.data[0].amount' <<< $d)
    currency=$(jq -r '.data[0].currency' <<< $d)

    echo "$message"
    echo
    echo "$username, $amount $currency"
}

while true; do
    t=$(curl -s livingroom.lan/sensor/outside | jq -r '.state')
    label="$(date '+%F %R')  $t  $(lx) lux  ISO:$(get_state iso) EV:$(get_state ev)"
    #echo -e "\n$label"
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

