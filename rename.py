from datetime import datetime, timedelta
import glob, os
files = [f for f in glob.glob('*-at-*.mp4')]
#print(files)
def get_first_part(filename):
	return filename.split(".mkv-at-")[0]

def get_second_part(filename):
	x = filename.split(".mkv-at-")[1]
	return x[:len(x)-4]

gfp = get_first_part
gsp = get_second_part

def get_date(filename):
	part = gfp(filename)
	date = datetime.strptime(part, "%Y-%m-%d_%H:%M")
	return date

def get_length(filename):
	part = gsp(filename)
	millis = part[len(part)-3:]
	date = datetime.strptime(part, "%H:%M:%S.%f")
	delta = timedelta(minutes=date.minute, hours=date.hour)
	return delta
def generate_final(a, date):
	return f"{date.strftime('%Y-%m-%d_%H:%M')}.mp4"

for file in files:
	length = get_length(file)
	os.rename(file, generate_final(file, get_date(file) + length))
