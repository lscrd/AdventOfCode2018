import strscans
import strutils
import tables
import intsets

type Coords = tuple[x, y: int]

var locations: seq[Coords]

const
  MIN = -10000    # Minimum value for coordinates.
  MAX = 10000     # Maximum value for coordinates.

var
  xmin, ymin = MAX    # Minimal value for x.
  xmax, ymax = MIN    # Maximal value for y.
for line in "data".lines:
  var x, y: int
  discard line.scanf("$i, $i", x, y)
  if x < xmin: xmin = x
  if x > xmax: xmax = x
  if y < ymin: ymin = y
  if y > ymax: ymax = y
  locations.add((x, y))

# Adjust min and max to cover one position larger in each direction.
dec xmin
inc xmax
dec ymin
inc ymax

# Manhattan distance.
proc distance(x1, y1, x2, y2: int): int {.inline.} = abs(x2 - x1) + abs(y2 - y1)

# Compute the distances and find the closest location.
const NONE = -1
var closestLocation = initTable[Coords, int]()
for x in xmin..xmax:
  for y in ymin..ymax:
    var dist = MAX
    var locidx = NONE
    for idx, coords in locations:
      let d = distance(x, y, coords.x, coords.y)
      if d < dist:
        # Found a shorter distance.
        locidx = idx
        dist = d
      elif dist == d:
        # Several locations at shortest distance.
        locidx = NONE
        dist = d
    closestLocation[(x, y)] = locidx

# Eliminate locations that have a minimal distance at borders.
var candidates = initIntSet()
for idx in 0..locations.high:
  candidates.incl(idx)
for y in ymin..ymax:
  candidates.excl(closestLocation[(xmin, y)])
  candidates.excl(closestLocation[(xmax, y)])
for x in (xmin + 1)..(xmax - 1):
  candidates.excl(closestLocation[(x, ymin)])
  candidates.excl(closestLocation[(x, ymax)])

# Find the maximal area.
var areas = newSeq[int](locations.len)
for x in (xmin + 1)..(xmax - 1):
  for y in (ymin + 1)..(ymax - 1):
    let locidx = closestLocation[(x, y)]
    if locidx in candidates:
      inc areas[locidx]

echo max(areas)
