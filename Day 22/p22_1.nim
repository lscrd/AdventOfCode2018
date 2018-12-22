import strscans
import strutils
import tables

type
  RegionType = enum rocky, wet, narrow
  Coords = tuple[x, y: int]
  ErosionLevel = seq[seq[int]]
  Cave = seq[seq[RegionType]]

var
  depth: int
  target: Coords
  erosionLevel: ErosionLevel
  cave: Cave

# Symbols for drawing.
const symbol: array[RegionType, char] = ['.', '=', '|']

# Parse input data.
var data = ["depth: 510", "target: 10,10"]
# var data = "data".readFile().splitLines()
discard data[0].scanf("depth: $i", depth)
discard data[1].scanf("target: $i,$i", target.x, target.y)

# Compute the geological index.
proc geologicalIndex(elevel: ErosionLevel; region, target: Coords): int =
  if region == target:
    result = 0
  elif region.x == 0:
    result = region.y * 48271   # Works for (0, 0).
  elif region.y == 0:
    result = region.x * 16807
  else:
    result = elevel[region.x - 1][region.y] * elevel[region.x][region.y - 1]

# Display the map of the cave.
proc display(cave: Cave, target: Coords) {.used.} =
  const origin = (0, 0)
  for y in 0..cave[0].high:
    var line = ""
    for x in 0..cave.high:
      let coords = (x, y)
      if coords == origin:
        line.add('M')
      elif coords == target:
        line.add('T')
      else:
        line.add(symbol[cave[x][y]])
    echo line

# Create area. For part 1, we can limit to the rectangle from (0, 0) to target.
let ysize = target.y + 1
for x in 0..target.x:
  erosionLevel.add(newSeq[int](ysize))
  cave.add(newSeq[RegionType](ysize))
  for y in 0..target.y:
    let elevel = (erosionLevel.geologicalIndex((x, y), target) + depth) mod 20183
    erosionLevel[x][y] = elevel
    cave[x][y] = RegionType(elevel mod 3)

# cave.display()

# Compute the risk level.
var riskLevel = 0
for x in 0..target.x:
  for y in 0.. target.y:
    inc riskLevel, ord(cave[x][y])
echo riskLevel
