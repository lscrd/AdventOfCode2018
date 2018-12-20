import strscans
import strutils

type Coords = tuple[x, y: int]

var locations: seq[Coords]

const
  MIN = -10000    # Minimum value for coordinates.
  MAX = 10000     # Maximum value for coordinates.
  M = 10000       # Maximum sum of distances.

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

# Adjust min and max to cover the working area.
let delta = M div locations.len
dec xmin, delta
inc xmax, delta
dec ymin, delta
inc ymax, delta

# Manhattan distance.
proc distance(x1, y1, x2, y2: int): int {.inline.} = abs(x2 - x1) + abs(y2 - y1)

# Compute the distances and count the suitable locations.
var count = 0
for x in xmin..xmax:
  for y in ymin..ymax:
    var dist = 0
    for idx, coords in locations:
      inc dist, distance(x, y, coords.x, coords.y)
      if dist >= M:
        break   # Too much.
    if dist < M:
      # Found a suitable location.
      inc count

echo count
