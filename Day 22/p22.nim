import std/[strscans, strutils, tables]

type
  RegionType {.pure.} = enum Rocky = ".", Wet = "=", Narrow = "|"
  Position = tuple[x, y: int]
  ErosionLevels = seq[seq[int]]
  Cave = seq[seq[RegionType]]

var
  depth: int
  target: Position

# Parse input data.
let data = readFile("p22.data").splitLines()
discard data[0].scanf("depth: $i", depth)
discard data[1].scanf("target: $i,$i", target.x, target.y)

proc geologicalIndex(eLevels: ErosionLevels; region, target: Position): int =
  ## Compute the geological index.
  if region == target:
    result = 0
  elif region.x == 0:
    result = region.y * 48271   # Works for (0, 0).
  elif region.y == 0:
    result = region.x * 16807
  else:
    result = eLevels[region.x - 1][region.y] * eLevels[region.x][region.y - 1]

proc display(cave: Cave; target: Position) {.used.} =
  ## Display the map of the cave.
  const origin = (0, 0)
  for y in 0..cave[0].high:
    var line = ""
    for x in 0..cave.high:
      let coords = (x, y)
      if coords == origin:
        line.add 'M'
      elif coords == target:
        line.add 'T'
      else:
        line.add $cave[x][y]
    echo line

proc createCave(target: Position; depth: int; xsize, ysize: int): Cave =
  ## Create the cave description.
  var erosionLevels: ErosionLevels
  for x in 0..<xsize:
    erosionLevels.add newSeq[int](ysize)
    result.add newSeq[RegionType](ysize)
    for y in 0..<ysize:
      let eLevel = (erosionLevels.geologicalIndex((x, y), target) + depth) mod 20183
      erosionLevels[x][y] = eLevel
      result[x][y] = RegionType(eLevel mod 3)


### Part 1 ###

# Create cave. For part 1, we limit to the rectangle from (0, 0) to target.
let cave1 = createCave(target, depth, target.x + 1, target.y + 1)

# Compute the risk level.
var riskLevel = 0
for x in 0..target.x:
  for y in 0.. target.y:
    inc riskLevel, ord(cave1[x][y])

echo "Part 1: ", riskLevel


### Part 2 ###

type

  # Types to manage tools and times.
  Tool {.pure.} = enum None, Torch, ClimbingGear
  Time = array[Tool, int]   # Times to reach the point with each possible tool.
  Times = seq[seq[Time]]    # List of times for each region.

  # Description of a move.
  Move = tuple[startPos, endPos: Position; tool: Tool]


const
  # Forbidden tool for each region type.
  ForbiddenTool = [Rocky: None, Wet: Torch, Narrow: ClimbingGear]
  # Allowed tools for each region type.
  AllowedTools = [Rocky: {Torch, ClimbingGear}, Wet: {None, ClimbingGear}, Narrow: {None, Torch}]
  # Given a tool, other tool that can be used for each region type.
  OtherTool = {(Rocky, Torch): ClimbingGear,
               (Rocky, ClimbingGear): Torch,
               (Narrow, None): Torch,
               (Narrow, Torch): None,
               (Wet, None): ClimbingGear,
               (Wet, ClimbingGear): None}.toTable()

const Infinity = 100_000                  # Infinity value used as default.
let MaxTime = 8 * (target.x + target.y)   # Maximum acceptable time.

iterator accessibleFromWith(cave: Cave; fromPos: Position; tool: Tool): Position =
  ## Yield the regions which are accessible from the region at "fromPos" with "tool".
  let (x, y) = fromPos
  let x1 = x - 1
  let x2 = x + 1
  let y1 = y - 1
  let y2 = y + 1
  if x1 >= 0 and ForbiddenTool[cave[x1][y]] != tool:
    yield (x1, fromPos.y)
  if x2 <= cave.high and ForbiddenTool[cave[x2][y]] != tool:
    yield (x2, fromPos.y)
  if y1 >= 0 and ForbiddenTool[cave[x][y1]] != tool:
    yield (fromPos.x, y1)
  if y2 <= cave[0].high and ForbiddenTool[cave[x][y2]] != tool:
    yield (fromPos.x, y2)


proc walk(cave: Cave; times: var Times; target: Position) =
  ## Walk and compute minimal times for each path and each tool.
  ## Recursivity is not possible, so we have to use our own stack.

  var moves: seq[Move]    # Stack of moves.

  # Initialize the stack of moves.
  for tool in AllowedTools[cave[0][0]]:
    for nextPos in cave.accessibleFromWith((0, 0), tool):
      moves.add ((0, 0), nextPos, tool)

  var minTime = MaxTime   # Used to avoid updating too large times => important speed up.
  while moves.len > 0:
    let (current, next, tool) = moves.pop()
    if current == target:
      # Set minTime to the maximum of the two current times to target.
      let targetTimes = times[target.x][target.y]
      minTime = max(targetTimes[Torch], targetTimes[ClimbingGear])
      continue
    # Update time for "next" with the current tool.
    var newTime = times[current.x][current.y][tool] + 1
    var changed = false
    if newTime < minTime and newTime < times[next.x][next.y][tool]:
      times[next.x][next.y][tool] = newTime
      changed = true
    # Update time for "next" with the other possible tool.
    let oTool = OtherTool[(cave[next.x][next.y], tool)]
    inc newtime, 7
    if newTime < minTime and newTime < times[next.x][next.y][oTool]:
      times[next.x][next.y][otool] = newTime
      changed = true
    # Some changed has been done. Add new moves from "next" to the stack of moves.
    if changed:
      for tool in AllowedTools[cave[next.x][next.y]]:
        for pos in cave.accessibleFromWith(next, tool):
          if pos != current:
            moves.add (next, pos, tool)


# Create area. For part 2, we have to add extra regions.
const
  # The following values are extremely conservative. We get the right result with
  # DeltaX = 30 and DeltaY = 1 but the final checks fail and require higher values.
  DeltaX = 138    # The number of regions to add along the x coordinate.
  DeltaY = 2      # The number of regions to add along the y coordinate.
let xsize = target.x + DeltaX
let ysize = target.y + DeltaY
let cave2 = createCave(target, depth, xsize, ysize)

# Create times array.
var times: Times
times.setLen(xsize)
for tx in times.mitems:
  tx.setLen(ysize)
  for ty in tx.mitems:
    ty = [Infinity, Infinity, Infinity]
times[0][0] = [Infinity, 0, 7]
times[target.x][target.y] = [Infinity, MaxTime, MaxTime]

cave2.walk(times, target)
let minTime = times[target.x][target.y][Torch]

# Check if it may be necessary to extend area.
var mtime = minTime - 1   # We want a value strictly less than the minimum time found.
let maxx = xsize - 1
let maxy = ysize - 1
let dmaxx = maxx - target.x   # Distance from maximum x border to target.
let dmaxy = maxy - target.y   # Distance from maximum y border to target.
block checkx:
  for y in 0..<ysize:
    for tool in None..ClimbingGear:
      if times[maxx][y][tool] + dmaxx + abs(y - target.y) < mTime:
        echo "Increase x", " ", times[maxx][y][tool] + dmaxx + abs(y - target.y)
        break checkx
block checky:
  for x in 0..<xsize:
    for tool in None..ClimbingGear:
      if times[x][maxy][tool] + abs(x - target.x) + dmaxy < mTime:
        echo "Increase y"
        break checky

echo "Part 2: ", minTime
