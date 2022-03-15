import pandas as pd
import sys

print('reading '+sys.argv[1])
d = pd.read_csv(sys.argv[1], sep='\t', header=None, names=['pts', 'mvs'])
d['w6'] = d['mvs'].rolling(window=6, center=True).mean()
d['w60'] = d['mvs'].rolling(window=60, center=True).mean()
d['w600'] = d['mvs'].rolling(window=600, center=True).mean()
d['w6000'] = d['mvs'].rolling(window=6000, center=True).mean()*2
df = d[(d['w6'] > d['w6000'])]
d.to_csv(sys.argv[1]+'-mean.tsv', sep='\t')
df.to_csv(sys.argv[1]+'-mean-filter.tsv', sep='\t')

