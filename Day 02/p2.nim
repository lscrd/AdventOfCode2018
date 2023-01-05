import std/tables


### Part 1 ###

var count2, count3 = 0

for line in lines("p2.data"):
  let counts = line.toCountTable()
  var has2, has3 = false
  for count in counts.values:
    if count == 2:
      has2 = true
      if has3: break
    elif count == 3:
      has3 = true
      if has2: break
  if has2: inc count2
  if has3: inc count3

echo "Part 1: ", count2 * count3


### Part 2 ###

import std/[sequtils, strutils]

let ids = toSeq(lines("p2.data"))

proc search(ids: seq[string]): string =
  ## Search the common part of the two correct box IDs.

  const Nofit = -1  # No difference or more than one difference.
  let idMaxIdx = ids[0].high  # Maximum index for IDs.

  for idx1 in 0..(ids.high - 1):
    var id1 = ids[idx1]

    for idx2 in (idx1 + 1)..ids.high:
      let id2 = ids[idx2]
      var diffIdx = NoFit

      # Compare IDs to find differences.
      for i in 0..idMaxIdx:
        if id1[i] != id2[i]:
          if diffIdx >= 0:
            # Already found a difference.
            diffIdx = NoFit
            break
          diffIdx = i

      if diffIdx != NoFit:
        # Found the two IDs. Keep the common part.
        id1.delete(diffIdx..diffIdx)
        return id1

echo "Part 2: ", ids.search()
