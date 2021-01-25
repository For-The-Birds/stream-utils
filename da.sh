set -euvx

. ./da_secrets.sh

scope=oauth-donation-index
response_type=code
redirect_uri=http://localhost:7778

code=$1

curl -X POST https://www.donationalerts.com/oauth/token \
    -v -H "Content-Type: application/x-www-form-urlencoded" \
    -d grant_type="authorization_code" \
    -d client_id=$client_id \
    -d client_secret=$client_secret \
    -d code=$code \
    -d redirect_uri="$redirect_uri" \
    -o token.json

