
tqs=$((1024 * 128))

if [ -n "$ASSERVICE" ]; then
    ffopts="-nostdin -loglevel error"
else
    ffopts="-loglevel info"
fi

BDIR=/mnt/birds/pivid
SRCDIR=$PWD/$(dirname ${BASH_SOURCE[0]})/
PATH=$SRCDIR:$PATH
