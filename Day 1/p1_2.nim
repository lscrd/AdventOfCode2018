import strutils
import intsets

var changelist: seq[int]
var freqset = initIntSet()
freqset.incl(0)

# Read the list for frequencies.
for line in "puzzle1".lines:
  changelist.add(line.parseInt())

## Yield the next change looping in the list of changes.
iterator freqchanges(): int =
  while true:
    for change in changelist:
      yield change

var freq = 0
for change in freqchanges():
  freq += change
  if freq in freqset:
    break
  freqset.incl(freq)

echo freq
