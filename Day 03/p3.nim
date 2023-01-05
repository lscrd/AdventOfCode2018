import std/[sets, strscans]

type

  # Description of a claim.
  Claim = object
    id: int
    xstart, ystart, xend, yend: int

  # Description of a square of fabric.
  Square = tuple[x, y: int]

var claims: seq[Claim]        # List of claims.

proc buildClaim(line: string): Claim =
  ## Build a claim from a line.
  var width, height: int
  discard line.scanf("#$i @ $i,$i: $ix$i", result.id, result.xstart, result.ystart, width, height)
  result.xend = result.xstart + width - 1
  result.yend = result.ystart + height - 1


### Part 1 ###

proc overlap(newclaim: Claim; claims: seq[Claim]): HashSet[Square] =
  ## Return the overlap of the new claim with previous claims as a set of squares.
  for claim in claims:
    let xstart = max(claim.xstart, newclaim.xstart)
    let xend = min(claim.xend, newclaim.xend)
    let ystart = max(claim.ystart, newclaim.ystart)
    let yend = min(claim.yend, newclaim.yend)
    for x in xstart..xend:
      for y in ystart..yend:
        result.incl((x, y))

var squares: HashSet[Square]  # Set of squares belonging to several claims.
for line in lines("p3.data"):
  let claim = buildClaim(line)
  squares.incl(overlap(claim, claims))
  claims.add(claim)

echo "Part 1: ", card(squares)


### Part 2 ###

proc update(overlaps: var seq[bool], idx: int, claims: seq[Claim]): bool =
  let claim = claims[idx]
  # Update the list of indexes of claims which overlap with claim at index "idx".
  ## This includes this claim itself if it overlaps with some other claim.
  ## Return "true" is an update has been done, i.e. an overlap has been found, else "false".
  for i, otherclaim in claims:
    if idx == i: continue
    if result and overlaps[i]: continue  # No update to be done.
    if claim.xstart <= otherclaim.xend and claim.xend >= otherclaim.xstart and
       claim.ystart <= otherclaim.yend and claim.yend >= otherclaim.ystart:
        overlaps[i] = true
        result = true
  if result:
    overlaps[idx] = true

proc nonOverlappingClaim(claims: seq[Claim]): int =
  ## Return the ID of the non-overlapping claim.
  var overlaps = newSeq[bool](claims.len)    # Indicates which claims are known to overlap.
  for idx in 0..claims.high:
    if not overlaps[idx]:
      # We have found a candidate.
      if not overlaps.update(idx, claims):
        # No overlap for this claim. Stop search.
        return claims[idx].id

echo "Part 2: ", claims.nonOverlappingClaim()
