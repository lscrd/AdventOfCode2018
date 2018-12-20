# This version builds the list of claims before checking for overlap.
# It allows to use a simple list instead of a set and it is slightly faster.

import strscans
import strutils

type
  # Description of a claim.
  Claim = object
    id: int
    xstart, ystart, xend, yend: int

var
  claims: seq[Claim]    # List of claims.
  overlap: seq[bool]    # Indicates what claims are known to overlap.

## Build a claim from a line.
proc buildClaim(line: string): Claim =
  var width, height: int
  discard line.scanf("#$i @ $i,$i: $ix$i", result.id, result.xstart, result.ystart, width, height)
  result.xend = result.xstart + width - 1
  result.yend = result.ystart + height - 1

## Update the list of indexes of claims which overlap with claim at index "idx".
## This includes this claim itself if it overlaps with some other claim.
## Return "true" is an update has been done, i.e. an overlap has been found, else "false".
proc update(overlap: var seq[bool], idx: int, claims: seq[Claim]): bool =
  let claim = claims[idx]
  for i, otherclaim in claims:
    if idx == i: continue
    if result and overlap[i]: continue  # No update to be done.
    if claim.xstart <= otherclaim.xend and claim.xend >= otherclaim.xstart and
       claim.ystart <= otherclaim.yend and claim.yend >= otherclaim.ystart:
        overlap[i] = true
        result = true
  if result:
    overlap[idx] = true

# Build the list of claims.
for line in "puzzle3".lines:
  claims.add(buildClaim(line))
overlap.setLen(claims.len)

for idx in 0..claims.high:
  if not overlap[idx]:
    # We have found a candidate.
    if not overlap.update(idx, claims):
      # No overlap for this claim. Stop search.
      echo claims[idx].id
      break
