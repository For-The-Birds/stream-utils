
tqs=$((1024 * 128))

if [ -n "$ASSERVICE" ]; then
    ffopts="-nostdin -loglevel warning"
else
    ffopts="-loglevel info"
fi

BDIR=/mnt/birds
SRCDIR=$PWD/$(dirname "$(readlink ${BASH_SOURCE[0]})")/
PATH=$SRCDIR:$PATH

acat () {
    zcat $1 || cat $1
}

export -f acat
