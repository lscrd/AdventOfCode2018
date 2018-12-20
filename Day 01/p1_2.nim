import strutils
import intsets

var changelist: seq[int]
var freqset = initIntSet()
freqset.incl(0)

# Read the list for frequencies.
for line in "data".lines:
  changelist.add(line.parseInt())

## Yield the next change looping in the list of changes.
iterator freqchanges(changelist: seq[int]): int =
  while true:
    for change in changelist:
      yield change

var freq = 0
for change in changelist.freqchanges():
  freq += change
  if freq in freqset:
    break
  freqset.incl(freq)

echo freq
