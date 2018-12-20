# Using "clear" to avoid allocation of a new table is a wrong idea.
# It is awfully slow , so the program takes about seven times more times to run
# than simply using "initTable".

import algorithm
import sets
import strutils
import strformat
import tables

type
  Area = seq[seq[char]]         # The area as an array of arrays of characters.
  Position = tuple[i, j: int]   # Position in the area.
  Path = seq[Position]          # Representation of a path.
  Unit = ref object             # Representation of a unit.
    kind: char                  # Kind of unit.
    foe: char                   # Kind of unit foe.
    pos: Position               # Unit position.
    hp: int                     # Unit health points.
    ap: int                     # Unit attack power.

const
  NO_POSITION: Position = (1000, 1000)      # Special value when position is not relevant.
  NONE = 1000                               # Special value when vlue is not relevant.

var
  area: Area          # Area description.
  units: seq[Unit]    # Description of units.
  elves: seq[Unit]    # List of elves units.
  elfKilled: bool     # Indicate if an elf has been killed.
  goblinCount: int    # Count of goblins.
  rounds = 0          # Count of full rounds.
  data: seq[string]   # List of lines read from file.

# Read lines from file.
data = "data".readFile().split('\n')

# Cache to keep the paths.
type CacheKey = tuple[fromPos, toPos: Position; length: int]
var pathCache: Table[CacheKey, seq[Path]]

# Create a new unit.
proc newUnit(kind: char; i, j: int; ap: int): Unit =
  new result
  result.kind = kind
  result.foe = if kind == 'E': 'G' else: 'E'
  result.pos = (i, j)
  result.hp = 200
  result.ap = ap

# Create string description of a unit.
proc `$`(unit: Unit): string {.used.} =
  fmt"{unit.kind}({unit.pos.i},{unit.pos.j})"

# Display the area.
proc display() {.used.} =
  for row in area:
    echo row.join()
  echo ""

# Initialize the simulation with attack points "ap" for elves.
proc initSimulation(data: seq[string], ap: int) =
  area = @[]
  units = @[]
  elves = @[]
  goblinCount = 0
  var i = -1
  for line in data:
    inc i
    var j = -1
    area.add(@[])
    for c in line:
      inc j
      area[^1].add(c)
      if c == 'E':
        let unit = newUnit(c, i, j, ap)
        units.add(unit)
        elves.add(unit)
      elif c == 'G':
        units.add(newUnit(c, i, j, 3))
        inc goblinCount

# Find unit at position (i, j).
proc unitAt(i, j: int): Unit =
  let pos: Position = (i, j)
  for unit in units:
    if unit.hp > 0 and unit.pos == pos:
      return unit

# Yield the positions adjacent to "pos".
iterator adjacents(pos: Position): Position =
  yield (pos.i - 1, pos.j)
  yield (pos.i, pos.j - 1)
  yield (pos.i, pos.j + 1)
  yield (pos.i + 1, pos.j)

# Yield the positions adjacent to "pos" which are free.
iterator freeAdjacents(pos: Position): Position =
  if area[pos.i - 1][pos.j] == '.':
    yield (pos.i - 1, pos.j)
  if area[pos.i][pos.j - 1] == '.':
    yield (pos.i, pos.j - 1)
  if area[pos.i][pos.j + 1] == '.':
    yield (pos.i, pos.j + 1)
  if area[pos.i + 1][pos.j] == '.':
    yield (pos.i + 1, pos.j)

# Find the targets adjacent to a unit.
proc targets(unit: Unit): seq[Unit] =
  for pos in unit.pos.adjacents():
    if area[pos.i][pos.j] == unit.foe:
      result.add(unitAt(pos.i, pos.j))

# Find the positions which are in range for a unit.
proc inRange(unit: Unit): HashSet[Position] =
  result = initSet[Position]()
  for other in units:
    if other.hp <= 0 or other.kind != unit.foe: continue  # Not relevant.
    for pos in other.pos.freeAdjacents():
      result.incl(pos)

# Find the length of the shortest path from "srcPos" to "dstPos".
# Return NONE if "dstPos" is unreachable from "srcPos".
proc pathLength(srcPos, dstPos: Position): int =
  result = 0
  var currpos = initSet[Position]()
  var nextpos = initSet[Position]()
  currpos.incl(srcPos)
  while dstPos notin currpos:
    inc result
    for pos in currpos:
      for freepos in pos.freeAdjacents():
        nextpos.incl(freepos)
    if nextpos == currpos:
      result = NONE
      break
    currpos = nextpos

# Find the nearest positions reachable by a unit and the length of the shortest paths.
proc nearest(unit: Unit, posSet: HashSet[Position]): tuple[length: int, positions: seq[Position]] =
  result.length = NONE
  for pos in posSet:
    let length = pathLength(unit.pos, pos)
    if length < result.length:
      result.length = length
      result.positions.setLen(0)
      result.positions.add(pos)
    elif length != NONE and length == result.length:
      result.positions.add(pos)

# Find the paths of length "length" from "srcPos", to "dstPos".
proc paths(srcPos, dstPos: Position; length: int): seq[Path] =
  if srcPos == dstPos:
    return @[@[dstPos]]
  if length == 0:
    return @[]
  let key = (srcPos, dstPos, length)
  if key in pathCache:
    return pathCache[key]
  for nextPos in srcPos.freeAdjacents():
    for path in paths(nextPos, dstPos, length - 1):
      result.add(srcPos & path)
  pathCache[key] = result

# Compare two units by their positions in "area".
proc unitCompare(unit1, unit2: Unit): int = cmp(unit1.pos, unit2.pos)

# Execute a round. Return true if the round was a full round, else false.
proc fullRound(): bool =
  result = true
  for unit in units.mitems:
    if unit.hp <= 0:
      continue      # Killed unit.
    if goblinCount == 0:
      return false  # Round has been interrupted before its end.
    var targets = unit.targets()
    if targets.len == 0:
      # No adjacent target, so do a move.
      let (length, positions) = unit.nearest(unit.inRange())
      if positions.len == 0:
        continue    # No reachable position.
      let chosen = sorted(positions, system.cmp)[0]
      # Search best path.
      var nextpos = NO_POSITION
      pathCache = initTable[CacheKey, seq[Path]]()
      for path in paths(unit.pos, chosen, length):
        if path.len > 1 and path[1] < nextpos:
          nextpos = path[1]
      # Do the move.
      if nextpos != NO_POSITION:
        area[unit.pos.i][unit.pos.j] = '.'
        area[nextpos.i][nextpos.j] = unit.kind
        unit.pos = nextpos
        targets = unit.targets()  # Search adjacent targets.
    if targets.len != 0:
      # Combat. Choose the target.
      var target: Unit = nil
      for t in targets:
        if isNil(target) or t.hp < target.hp:
          target = t
      # Do the fight.
      dec target.hp, unit.ap
      if target.hp <= 0:
        # Target killed.
        area[target.pos.i][target.pos.j] = '.'
        target.pos = NO_POSITION
        if target.kind == 'E':
          elfKilled = true
          return
        else:
          dec goblinCount

  # Sort units for next round.
  units.sort(unitCompare)

# Run the simulation with increasing attack points for elves.
var ap = 3
while true:
  inc ap
  echo "Trying AP = ", ap
  initSimulation(data, ap)
  elfKilled = false
  rounds = 0
  while goblinCount != 0:
    if fullRound():
      inc rounds
    if elfKilled:
      break   # We must try with more attack points.
  if goblinCount == 0:
    break

# Compute outcome.
var hp = 0
for unit in elves:
  if unit.hp > 0:
    inc hp, unit.hp
echo ""
echo "Rounds: ", rounds
echo "Attack points: ", rounds
echo "Outcome: ", rounds * hp
