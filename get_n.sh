set -vx

function get_n {
    v=$(curl -X GET -H "Authorization: Bearer $(<.ha.token)" -H "Content-Type: application/json" http://homeassistant.lan:8123/api/states/input_number.$1)

    v=$( echo "$v" | jq '.state' | tr -d '"' )
    v=$(printf '%.0f' "$v")
    echo $v
}

get_n $@
