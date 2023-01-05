import std/[intsets, strscans, tables]

type
  Location = tuple[x, y: int]
  Locations = seq[Location]
  Bounds = tuple[xmin, xmax, ymin, ymax: int]

const
  Min = -10000    # Minimum value for coordinates.
  Max =  10000    # Maximum value for coordinates.

var
  locations: Locations
  bounds: Bounds = (Max, Min, Max, Min)

# Read the location file.
for line in lines("p6.data"):
  var x, y: int
  discard line.scanf("$i, $i", x, y)
  if x < bounds.xmin: bounds.xmin = x elif x > bounds.xmax: bounds.xmax = x
  if y < bounds.ymin: bounds.ymin = y elif y > bounds.ymax: bounds.ymax = y
  locations.add((x, y))

# Adjust min and max to cover one position larger in each direction.
dec bounds.xmin
inc bounds.xmax
dec bounds.ymin
inc bounds.ymax

# Manhattan distance.
proc distance(x1, y1, x2, y2: int): int {.inline.} = abs(x2 - x1) + abs(y2 - y1)


### Part 1 ###

# Mapping of coordinates to index of closest location.
type ClosestLocations = Table[Location, int]

proc findClosestLocations(locations: Locations; bounds: Bounds): ClosestLocations =
  ## Compute the distances and find the closest locations.
  const None = -1
  for x in bounds.xmin..bounds.xmax:
    for y in bounds.ymin..bounds.ymax:
      var dist = Max
      var locIdx = None
      for idx, coords in locations:
        let d = distance(x, y, coords.x, coords.y)
        if d < dist:
          # Found a shorter distance.
          locIdx = idx
          dist = d
        elif dist == d:
          # Several locations at shortest distance.
          locIdx = None
      result[(x, y)] = locIdx

proc findCandidates(locations: Locations;
                    bounds: Bounds;
                    closestLocations: ClosestLocations): IntSet =
  ## Find the indexes of the candidate positions.

  for idx in 0..locations.high:
    result.incl(idx)

  # Eliminate locations which have a minimal distance at borders.
  for y in bounds.ymin..bounds.ymax:
    result.excl(closestLocations[(bounds.xmin, y)])
    result.excl(closestLocations[(bounds.xmax, y)])
  for x in (bounds.xmin + 1)..(bounds.xmax - 1):
    result.excl(closestLocations[(x, bounds.ymin)])
    result.excl(closestLocations[(x, bounds.ymax)])


let closestLocations = locations.findClosestLocations(bounds)
let candidates = locations.findCandidates(bounds, closestLocations)

# Find the largest area.
var areas = newSeq[int](locations.len)
for x in (bounds.xmin + 1)..(bounds.xmax - 1):
  for y in (bounds.ymin + 1)..(bounds.ymax - 1):
    let locIdx = closestLocations[(x, y)]
    if locIdx in candidates:
      inc areas[locIdx]

echo "Part 1: ", max(areas)


### Part 2 ###

const M = 10000   # Maximum sum of distances.

# Compute the distances and count the suitable locations.
var count = 0
for x in bounds.xmin..bounds.xmax:
  for y in bounds.ymin..bounds.ymax:
    var dist = 0
    for idx, coords in locations:
      inc dist, distance(x, y, coords.x, coords.y)
      if dist >= M:
        break     # Too much.
    if dist < M:
      inc count   # Found a suitable location.

echo "Part 2: ", count
