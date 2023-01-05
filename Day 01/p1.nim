import std/[intsets, math, strutils]

# Read frequence changes.
var changeList: seq[int]
for line in lines("p1.data"):
  changeList.add line.parseInt()


### Part 1 ###
echo "Part 1: ", sum(changeList)


### Part 2 ###

iterator freqChanges(changeList: seq[int]): int =
  ## Yield the next change looping in the list of changes.
  while true:
    for change in changelist:
      yield change

var freqSet = [0].toIntSet()

var freq = 0
for change in changeList.freqChanges():
  freq += change
  if freq in freqSet: break
  freqSet.incl(freq)

echo "Part 2: ", freq
