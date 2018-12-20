import strscans
import strutils
import sets

type

  # Description of a claim.
  Claim = object
    id: int
    xstart, ystart, xend, yend: int

  # Description of a square of fabric.
  Square = tuple[x, y: int]

var
  claims: seq[Claim]            # List of claims.
  squares = initSet[Square]()   # List of squares belonging to several claims.

## Build a claim from a line.
proc buildClaim(line: string): Claim =
  var width, height: int
  discard line.scanf("#$i @ $i,$i: $ix$i", result.id, result.xstart, result.ystart, width, height)
  result.xend = result.xstart + width - 1
  result.yend = result.ystart + height - 1

## Return the overlap of the new claim with previous claims as a set of squares.
proc overlap(newclaim: Claim, claims: seq[Claim]): HashSet[Square] =
  result = initSet[Square]()
  for claim in claims:
    let xstart = max(claim.xstart, newclaim.xstart)
    let xend = min(claim.xend, newclaim.xend)
    let ystart = max(claim.ystart, newclaim.ystart)
    let yend = min(claim.yend, newclaim.yend)
    for x in xstart..xend:
      for y in ystart..yend:
        result.incl((x, y))

for line in "data".lines:
  let claim = buildClaim(line)
  squares.incl(overlap(claim, claims))
  claims.add(claim)

echo squares.card
