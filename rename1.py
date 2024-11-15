#!/usr/bin/python

import datetime, glob, os, sys, re, fileinput, subprocess
# time ls -1 *-at-*.mp4 | parallel python rename1.py
ADELAY_PER_HOUR = 2.6

f = sys.argv[1].strip()
# reference : 2021-06-05_03:47.mkv-at-04:13:45.547.mp4
m = re.findall(r'(....-..-.._..:..).*-at-(..:..:[0-9]+\.[0-9]+).*\.mp4', f)
print(f, m, end=' ')
m1 = str(m[0][0]).rstrip('_')
m2 = m[0][1]
d = datetime.datetime.strptime(m1, "%Y-%m-%d_%H:%M")
at = datetime.datetime.strptime(m2, "%H:%M:%S.%f")
delta = datetime.timedelta(minutes=at.minute, hours=at.hour)
newname = (d + delta).strftime('%Y-%m-%d_%H:%M') + ".mp4"
#os.rename(f, newname)
nhours = at.hour + at.minute/60
print(nhours, newname)

ffmpegcmd = ('bash slice_fixup.sh "{0}" "{1}" "{2}"').format(
    f, int(nhours*ADELAY_PER_HOUR*1000), newname)
print(ffmpegcmd)
subprocess.run(ffmpegcmd, shell=True, check=True)
