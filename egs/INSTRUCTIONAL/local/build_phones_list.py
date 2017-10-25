import sys
from collections import Counter

# This script will generate a list of phones from a given lexicon

# sys.argv[1] = full/path/to/lexicon
# sys.argv[2] = full/path/to/write/out/phones

phones = Counter()

# get phones from lexicon
with open(sys.argv[1], 'r') as f:
  for line in f:
    if "\t" in line:
	line_split = line.rstrip().split("\t")
    else:
	line_split = line.rstrip().split()
    phones_in_word = line_split[1].split()
    for p in phones_in_word:
      phones[p] += 1

# sort phones
phones = list(phones)
phones.sort()

# write out the phones list
with open(sys.argv[2], 'w') as f:
  for p in phones:
    f.write("{}\n".format(p))

