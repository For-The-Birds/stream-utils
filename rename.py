from datetime import datetime, timedelta
import glob, os, sys, re, fileinput, subprocess
# ls -1 *-at-*.mp4 | grep -v adelay | python rename.py
# time ls -1 *-at-*.mp4 | egrep -v adelay | python ~/src/yekm/stream-utils/rename.py
ADELAY_PER_HOUR = 2.5

for f in fileinput.input():
    f = f.strip()
    # reference : 2021-06-05_03:47.mkv-at-04:13:45.547.mp4
    m = re.findall(r'(....-..-.._..:..).*-at-(..:..:[0-9]+\.[0-9]+).*\.mp4', f)
    print(f, m, end=' ')
    m1 = str(m[0][0]).rstrip('_')
    m2 = m[0][1]
    d = datetime.strptime(m1, "%Y-%m-%d_%H:%M")
    at = datetime.strptime(m2, "%H:%M:%S.%f")
    delta = timedelta(minutes=at.minute, hours=at.hour)
    newname = (d + delta).strftime('%Y-%m-%d_%H:%M') + ".mp4"
    #os.rename(f, newname)
    nhours = at.hour + at.minute/60
    print(nhours, newname)
    
    ffmpegcmd = ('ffmpeg -hide_banner -nostdin -y '
            '-i "{0}" -af adelay={1},loudnorm -to '
            '$(ffprobe -v error -select_streams v:0 -show_entries stream=duration '
                '-of default=noprint_wrappers=1:nokey=1 -sexagesimal "{0}") '
            '-c:v copy -c:a libopus '
            '"/mnt/nvme/pivid/{2}"').format(
        f, int(nhours*ADELAY_PER_HOUR*1000), newname)
    print(ffmpegcmd)
    subprocess.run(ffmpegcmd, shell=True, check=True)
