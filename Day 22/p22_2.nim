import strscans
import strutils
import tables

type
  # Types to build the cave representation.
  RegionType = enum rocky, wet, narrow
  Coords = tuple[x, y: int]       # Rows are x coordinates, columns are y coordinates.
  ErosionLevel = seq[seq[int]]
  Cave = seq[seq[RegionType]]

  # Types to manage tools and times.
  Tool = enum none, torch, climbingGear
  Time = array[Tool, int]   # Times to reach the point with each possible tool.
  Times = seq[seq[Time]]    # List of times for each region.

var
  depth: int
  target: Coords
  erosionLevel: ErosionLevel
  cave: Cave
  times: Times

# Symbols for drawing.
const symbol: array[RegionType, char] = ['.', '=', '|']

# Parse input data.
var data = "data".readFile().splitLines()
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

# Create area. For part2, we have to add extra regions.
const
  DELTAX = 138    # The number of regions to add along the x coordinate.
  DELTAY = 7      # The number of regions to add along the y coordinate.
let xsize = target.x + DELTAX
let ysize = target.y + DELTAY
for x in 0..<xsize:
  erosionLevel.add(newSeq[int](ysize))
  cave.add(newSeq[RegionType](ysize))
  for y in 0..<ysize:
    let elevel = (erosionLevel.geologicalIndex((x, y), target) + depth) mod 20183
    erosionLevel[x][y] = elevel
    cave[x][y] = RegionType(elevel mod 3)

const
  # Forbidden tool for each region type.
  forbiddenTool: array[RegionType, Tool] = [none, torch, climbingGear]
  # Allowed tools for each region type.
  allowedTools: array[RegionType, set[Tool]] = [{torch, climbingGear},
                                                {none, climbingGear},
                                                {none, torch}]
  # Given a tool, other tool that can be used for each region type.
  otherTool = [((rocky, torch), climbingGear),
               ((rocky, climbingGear), torch),
               ((narrow, none), torch),
               ((narrow, torch), none),
               ((wet, none), climbingGear),
               ((wet, climbingGear), none)].toTable()

# Description of a move.
type Move = tuple[startPos, endPos: Coords; tool: Tool]

# Yield the regions which are accessible from the region at "frompos" with "tool".
iterator accessibleFromWith(cave: Cave, frompos: Coords, tool: Tool): Coords =
  let (x, y) = frompos
  let x1 = x - 1
  let x2 = x + 1
  let y1 = y - 1
  let y2 = y + 1
  if x1 >= 0 and forbiddenTool[cave[x1][y]] != tool:
    yield (x1, fromPos.y)
  if x2 <= cave.high and forbiddenTool[cave[x2][y]] != tool:
    yield (x2, fromPos.y)
  if y1 >= 0 and forbiddenTool[cave[x][y1]] != tool:
    yield (fromPos.x, y1)
  if y2 <= cave[0].high and forbiddenTool[cave[x][y2]] != tool:
    yield (fromPos.x, y2)

# Create times array.
const INFINITY = 100000                   # Infinity value used as default.
let MAXTIME = 8 * (target.x + target.y)   # Maximum acceptable time.
times.setLen(xsize)
for tx in times.mitems:
  tx.setLen(ysize)
  for ty in tx.mitems:
    ty = [INFINITY, INFINITY, INFINITY]
times[0][0] = [INFINITY, 0, 7]
times[target.x][target.y] = [INFINITY, MAXTIME, MAXTIME]

# Walk and compute minimal times for each path and each tool.
# Recursivity is not possible, so we have to use our own stack.
proc walk(cave: Cave; times: var Times; target: Coords) =

  var moves: seq[Move]    # Stack of moves.

  # Initialize the stack of moves.
  for tool in allowedTools[cave[0][0]]:
    for nextPos in cave.accessibleFromWith((0, 0), tool):
      moves.add(((0, 0), nextPos, tool))

  var mintime = MAXTIME   # Used to avoid updating too large times => important speed up.
  while moves.len > 0:
    let (current, next, tool) = moves.pop()
    if current == target:
      # Set mintime to the maximum of the two current times to target.
      let targetTimes = times[target.x][target.y]
      mintime = max(targetTimes[torch], targetTimes[climbingGear])
      continue
    # Update time for "next" with the current tool.
    var newtime = times[current.x][current.y][tool] + 1
    var changed = false
    if newtime < mintime and newtime < times[next.x][next.y][tool]:
      times[next.x][next.y][tool] = newtime
      changed = true
    # Update time for "next" with the other possible tool.
    let otool = otherTool[(cave[next.x][next.y], tool)]
    inc newtime, 7
    if newtime < mintime and newtime < times[next.x][next.y][otool]:
      times[next.x][next.y][otool] = newtime
      changed = true
    # Some changed has been done. Add new moves from "next" to the stack of moves.
    if changed:
      for tool in allowedTools[cave[next.x][next.y]]:
        for pos in cave.accessibleFromWith(next, tool):
          if pos != current:
            moves.add((next, pos, tool))

cave.walk(times, target)
var mintime = times[target.x][target.y][torch]
echo mintime

# Check if it may be necessary to extend area.
dec mintime   # We want a value strictly less than the minimum time found.
let maxx = xsize - 1
let maxy = ysize - 1
let dmaxx = maxx - target.x   # Distance from maximum x border to target.
let dmaxy = maxy - target.y   # Distance from maximum y border to target.
block checkx:
  for y in 0..<ysize:
    for tool in none..climbingGear:
      if times[maxx][y][tool] + dmaxx + abs(y - target.y) < mintime:
        echo "Increase x", " ", times[maxx][y][tool] + dmaxx + abs(y - target.y)
        break checkx
block checky:
  for x in 0..<xsize:
    for tool in none..climbingGear:
      if times[x][maxy][tool] + abs(x - target.x) + dmaxy < mintime:
        echo "Increase y"
        break checky
