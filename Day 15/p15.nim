import std/[algorithm, sets, strutils, tables]

const Display = false   # True to display the area.

type

  Area = seq[seq[char]]         # The area as an array of arrays of characters.
  Position = tuple[r, c: int]   # Position in the area.
  Path = seq[Position]          # Representation of a path.

  Unit = ref object             # Representation of a unit.
    kind: char                  # Kind of unit.
    foe: char                   # Kind of unit foe.
    pos: Position               # Unit position.
    hp: int                     # Unit health points.
    ap: int                     # Unit attack power.

  Simulation = object
    area: Area                  # Area description.
    units: seq[Unit]            # Description of units.
    elveCount: int              # Count of elves.
    goblinCount: int            # Count of goblins.
    noElfKilled: bool           # True if simulation ends if an elf is killed.
    elfKilled: bool             # True if an elf has been killed (for part 2).
    fullRounds: int             # Number of full rounds executed.


const
  NoPosition: Position = (1000, 1000)     # Special value when position is not relevant.
  None = 1000                             # Special value when value is not relevant.

# Cache to keep the paths.
type CacheKey = tuple[fromPos, toPos: Position; length: int]
var pathCache: Table[CacheKey, seq[Path]]

# Read lines from file.
let data = readFile("p15.data").splitLines()

proc newUnit(kind: char; r, c: int; ap: int): Unit =
  ## Create a new unit.
  Unit(kind: kind, foe: if kind == 'E': 'G' else: 'E', pos: (r, c), hp: 200, ap: ap)

proc display(area: Area) =
  ## Display the area.
  for row in area:
    echo row.join()
  echo()

proc initSimulation(data: seq[string]; ap: int; noElfKilled: bool): Simulation =
  ## Initialize the simulation.
  result.noElfKilled = noElfKilled
  var row = -1
  for line in data:
    inc row
    var col = -1
    result.area.add @[]
    for c in line:
      inc col
      result.area[^1].add c
      if c == 'E':
        result.units.add newUnit(c, row, col, ap)
        inc result.elveCount
      elif c == 'G':
        result.units.add newUnit(c, row, col, 3)
        inc result.goblinCount

proc unitAt(sim: Simulation; r, c: int): Unit =
  ## Find unit at position (r, c).
  let pos: Position = (r, c)
  for unit in sim.units:
    if unit.hp > 0 and unit.pos == pos:
      return unit

iterator adjacents(pos: Position): Position =
  ## Yield the positions adjacent to "pos".
  yield (pos.r - 1, pos.c)
  yield (pos.r, pos.c - 1)
  yield (pos.r, pos.c + 1)
  yield (pos.r + 1, pos.c)

iterator freeAdjacents(sim: Simulation; pos: Position): Position =
  ## Yield the positions adjacent to "pos" which are free.
  if sim.area[pos.r - 1][pos.c] == '.':
    yield (pos.r - 1, pos.c)
  if sim.area[pos.r][pos.c - 1] == '.':
    yield (pos.r, pos.c - 1)
  if sim.area[pos.r][pos.c + 1] == '.':
    yield (pos.r, pos.c + 1)
  if sim.area[pos.r + 1][pos.c] == '.':
    yield (pos.r + 1, pos.c)

proc targets(sim: Simulation; unit: Unit): seq[Unit] =
  ## Find the targets adjacent to a unit.
  for pos in unit.pos.adjacents():
    if sim.area[pos.r][pos.c] == unit.foe:
      result.add sim.unitAt(pos.r, pos.c)

proc inRange(sim: Simulation; unit: Unit): HashSet[Position] =
  ## Find the positions which are in range for a unit.
  for other in sim.units:
    if other.hp <= 0 or other.kind != unit.foe: continue  # Not relevant.
    for pos in sim.freeAdjacents(other.pos):
      result.incl pos

proc pathLength(sim: Simulation; srcPos, dstPos: Position): int =
  ## Find the length of the shortest path from "srcPos" to "dstPos".
  ## Return None if "dstPos" is unreachable from "srcPos".
  var currPos, nextPos: HashSet[Position]
  currPos.incl srcPos
  while dstPos notin currpos:
    inc result
    for pos in currPos:
      for freePos in sim.freeAdjacents(pos):
        nextPos.incl freePos
    if nextPos == currPos:
      return None
    currPos = nextPos

proc nearest(sim: Simulation; unit: Unit; posSet: HashSet[Position]):
              tuple[length: int, positions: seq[Position]] =
  ## Find the nearest positions reachable by a unit and the length of the shortest paths.
  result.length = None
  for pos in posSet:
    let length = sim.pathLength(unit.pos, pos)
    if length < result.length:
      result.length = length
      result.positions.setLen(0)
      result.positions.add pos
    elif length != None and length == result.length:
      result.positions.add pos

proc paths(sim: Simulation; fromPos, toPos: Position; length: int): seq[Path] =
  ## Find the paths of length "length" from "srcPos", to "dstPos".
  if fromPos == toPos: return @[@[toPos]]
  if length == 0: return
  let key = (fromPos, toPos, length)
  if key in pathCache:
    return pathCache[key]
  for nextPos in sim.freeAdjacents(fromPos):
    for path in sim.paths(nextPos, toPos, length - 1):
      result.add fromPos & path
  pathCache[key] = result

proc unitCompare(unit1, unit2: Unit): int =
  ## Compare two units by their positions in "area".
  cmp(unit1.pos, unit2.pos)

proc doRound(sim: var Simulation) =
  ## Execute a round.

  for unit in sim.units.items:
    if unit.hp <= 0: continue    # Dead unit.
    var targets = sim.targets(unit)

    if targets.len == 0:
      # No adjacent target, so do a move.
      let (length, positions) = sim.nearest(unit, sim.inRange(unit))
      if positions.len == 0:
        continue  # No reachable position.
      let chosen = sorted(positions)[0]
      # Search best path.
      var nextPos = NoPosition
      pathCache.clear() # = initTable[CacheKey, seq[Path]]()
      for path in sim.paths(unit.pos, chosen, length):
        if path.len > 1 and path[1] < nextPos:
          nextPos = path[1]
      # Do the move.
      if nextPos != NoPosition:
        sim.area[unit.pos.r][unit.pos.c] = '.'
        sim.area[nextPos.r][nextPos.c] = unit.kind
        unit.pos = nextPos
        targets = sim.targets(unit)  # Search adjacent targets.

    if targets.len != 0:
      # Combat. Choose the target.
      var target: Unit = nil
      for t in targets:
        if target.isNil or t.hp < target.hp:
          target = t
      # Do the fight.
      dec target.hp, unit.ap
      if target.hp <= 0:
        # Target killed.
        sim.area[target.pos.r][target.pos.c] = '.'
        target.pos = NoPosition
        if target.kind == 'E':
          dec sim.elveCount
          if sim.noElfKilled:
            sim.elfKilled = true
            return
          if sim.elveCount == 0: return
        else:
          dec sim.goblinCount
          if sim.goblinCount == 0: return

  inc sim.fullRounds

  # Sort units for next round.
  sim.units.sort(unitCompare)

  if Display:
    sim.area.display()

proc outcome(sim: Simulation): int =
  ## Return the outcome of the combat.
  for unit in sim.units:
    if unit.hp > 0:
      inc result, unit.hp
  result *= sim.fullRounds


### Part 1 ###

# Run simulation.
var sim = initSimulation(data, 3, false)
while sim.elveCount != 0 and sim.goblinCount != 0:
  sim.doRound()

echo "Part 1: ", sim.outcome()


### Part 2 ###

proc successful(sim: var Simulation; data: seq[string]; ap: int): bool =
  ## Run a simulation and return true if is has been successful,
  ## i.e. no elf killed and all goblins killed.
  sim = initSimulation(data, ap, true)
  while sim.goblinCount != 0:
    sim.doRound()
    if sim.elfKilled:
      return false   # We must try with more attack points.
  result = true

# Run the simulation with increasing attack points for elves.
# To save a good amount of time, we start with a step of 10 then switch to a step of 1.
var ap = 4
for step in [10, 1]:
  while not sim.successful(data, ap):
    stdout.write '.'
    stdout.flushFile()
    inc ap, step
  if step != 1: dec ap, step - 1
echo()

echo "Part 2: ", sim.outcome()
