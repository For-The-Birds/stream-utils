from datetime import datetime, timedelta
import glob, os, sys, re
files = [f for f in glob.glob(sys.argv[1])]
#files = [f for f in glob.glob('*-at-*.mp4')]

for file in files:
    # reference : 2021-06-05_03:47.mkv-at-04:13:45.547.mp4
    m = re.findall(r'(....-..-.._..:..).*-at-(..:..:[0-9]+\.[0-9]+).*\.mp4', file)
    print(file, m, end=' ')
    m1 = str(m[0][0]).rstrip('_')
    m2 = m[0][1]
    d = datetime.strptime(m1, "%Y-%m-%d_%H:%M")
    l = datetime.strptime(m2, "%H:%M:%S.%f")
    delta = timedelta(minutes=l.minute, hours=l.hour)
    s = d + delta
    newname = s.strftime('%Y-%m-%d_%H:%M') + ".mp4"
    print(newname)
    #print(file, newname)
    #os.rename(file, newname)
