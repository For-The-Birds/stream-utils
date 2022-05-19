#set -e

. common.sh
cd $BDIR

time ls -1 *-at-*.mp4 | parallel -n1 -d '\n' python $SRCDIR/rename1.py
time catdays.sh

yu.sh

exit 0

ls -1 *.mp4 *.mkv | \
	sort -r | \
	sed '/mp4/,$d' | \
	tac | \
	head -n2 | \
	xargs -n 1 bash $SRCDIR/autocut/aautocut.sh
