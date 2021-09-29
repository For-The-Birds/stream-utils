
tqs=$((1024 * 128))

if [ -n "$ASSERVICE" ]; then
    ffopts="-nostdin -loglevel warning"
else
    ffopts="-loglevel info"
fi
