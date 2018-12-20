import strutils
import sequtils

var ids = toseq("puzzle2".lines)

let idmaxidx = ids[0].high  # Maximum index for ids.

proc search(ids: seq[string]): string =

  for idx1 in 0..(ids.high - 1):
    var id1 = ids[idx1]

    for idx2 in (idx1 + 1)..ids.high:
      let id2 = ids[idx2]
      var diffidx = -1      # -1 for 0 or more than 1 difference.

      # Compare ids to find differences.
      for i in 0..idmaxidx:
        if id1[i] != id2[i]:
          if diffidx >= 0:
            # Already found a difference.
            diffidx = -1
            break
          diffidx = i

      if diffidx >= 0:
        # Found the two ids.
        id1.delete(diffidx, diffidx)
        return id1

echo ids.search()
