
token=$(cat .token.json | jq '.access_token' | tr -d \")

curl -X GET https://www.donationalerts.com/api/v1/alerts/donations \
    -H "Authorization: Bearer $token"
