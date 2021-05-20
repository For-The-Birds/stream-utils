import glob
import os

files = [f for f in glob.glob('*.mp4')]

for f in files:
  t = f[f.find('-at-') + 4:f.rfind('.mp4')]
  if t.find(':') == -1:
    t = float(t)
  else:
    continue
  h = int(t // (60 * 60))
  t -= h * 60 * 60
  m = int(t // 60)
  t -= m * 60
  s = t
  t = f'{h:02}:{m:02}:{s:06.{3}f}'
  newname = f[:f.find('-at-') + 4] + str(t) + '.mp4'
  os.rename(f, newname)
  print(newname)
