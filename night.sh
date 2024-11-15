#set -e



export sdir=$(dirname ${BASH_SOURCE[0]})

source $sdir/common.sh

cd $BDIR/pivid

parallel -n1 rename1.py ::: *-at-*.mp4
catdays.sh

yu.sh

exit 0

pushd .
lastday=$(ls -1 $BDIR/nestbox/????-??-??_??:??.mkv | tail -n1 | cut -f1 -d_ | rev | cut -f1 -d/ | rev)

cd $BDIR/nestbox
parallel -n1 bash $SRCDIR/autocut/frame-pts.sh ::: $lastday*.mkv &

cd $SRCDIR/darknet
ls -1 $BDIR/nestbox/$lastday*.mkv | bash $SRCDIR/autocut/anestbox.sh
pigz $SRCDIR/darknet/nestbox/*.json
popd

exit 0

ls -1 *.mp4 *.mkv | \
	sort -r | \
	sed '/mp4/,$d' | \
	tac | \
	head -n2 | \
	xargs -n 1 bash $SRCDIR/autocut/aautocut.sh
