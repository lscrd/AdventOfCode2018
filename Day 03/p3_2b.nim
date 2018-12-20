# This version checks for overlap while parsing the file.
# This is the first version we have written.

import strscans
import strutils
import intsets

type
  # Description of a claim.
  Claim = object
    id: int
    xstart, ystart, xend, yend: int

var
  claims: seq[Claim]          # List of claims.
  noOverlap = initIntSet()    # Set of current non overlapping claim ids.

## Build a claim from a line.
proc buildClaim(line: string): Claim =
  var width, height: int
  discard line.scanf("#$i @ $i,$i: $ix$i", result.id, result.xstart, result.ystart, width, height)
  result.xend = result.xstart + width - 1
  result.yend = result.ystart + height - 1

## Return the list of claims which overlap with "newclaim".
## This includes "newclaim" itself if it overlaps with some other claim.
proc overlaps(newclaim: Claim, claims: seq[Claim]): seq[int] =
  for claim in claims:
    if newclaim.xstart <= claim.xend and newclaim.xend >= claim.xstart and
       newclaim.ystart <= claim.yend and newclaim.yend >= claim.ystart:
        result.add(claim.id)
  if result.len > 0:
    result.add(newclaim.id)

for line in "data".lines:
  let claim = buildClaim(line)
  let ids = overlaps(claim, claims)
  if ids.len > 0:
    # The new claim overlaps with some previous claims.
    for id in ids:
      noOverlap.excl(id)
  else:
    # The new claim doesn't overlap with previous claims.
    noOverlap.incl(claim.id)
  claims.add(claim)

echo noOverlap
