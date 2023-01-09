import std/[sequtils, strutils, tables]

type
  Position = tuple[row, col: int]
  Direction {.pure.} = enum North, East, South, West
  Walls = array[Direction, char]
  Rooms = OrderedTable[Position, Walls]

var
  rooms: Rooms
  regexp = readFile("p20.data")

const Empty = ['?', '?', '?', '?']    # Initial value for the walls of a room.

proc build(rooms: var Rooms; regexp: string; start: int; pos: Position): int {.discardable.} =
  # Build the rooms description. Return the last position in "regexp".
  result = start
  var pos = pos
  while true:
    case regexp[result]

    of '^':
      rooms[pos] = Empty
      inc result

    of 'N':
      rooms[pos][North] = '-'
      dec pos.row
      rooms.mgetOrPut(pos, Empty)[South] = '-'
      inc result

    of 'E':
      rooms[pos][East] = '|'
      inc pos.col
      rooms.mgetOrPut(pos, Empty)[West] = '|'
      inc result

    of 'S':
      rooms[pos][South] = '-'
      inc pos.row
      rooms.mgetOrPut(pos, Empty)[North] = '-'
      inc result

    of 'W':
      rooms[pos][West] = '|'
      dec pos.col
      rooms.mgetOrPut(pos, Empty)[East] = '|'
      inc result

    of '(':
      while true:
        # Process each part of the subexpression.
        result = rooms.build(regexp, result + 1, pos)
        if regexp[result] == ')':
          inc result
          break

    of '|', ')':
      break

    of '$':
      # Adjust walls.
      for roomPos, walls in rooms.pairs:
        for dir, wall in walls:
          if wall == '?':
            rooms[roomPos][dir] = '#'
      break

    else:
      discard

proc roomCmp(x, y: (Position, Walls)): int =
  ## Compare two room élements in the room table. To be used by "sort".
  cmp(x[0], y[0])

proc display(rooms: Rooms) {.used.} =
  ## Display the map of the rooms.
  const None = -10000000
  var map: seq[string]
  var row = None
  for pos, walls in rooms.pairs:
    if row != pos.row:
      row = pos.row
      map.add "#"
      map.add "#"
    map[^2].add walls[North]
    map[^2].add '#'
    map[^1].add '.'
    map[^1].add walls[East]
  # Add last line.
  map.add repeat("#", map[0].len)
  # Draw the map.
  for line in map:
    echo line

# Return the position of the room located at direction "dir' from room at "pos".
proc getPosition(pos: Position; dir: Direction): Position =
  case dir
  of North:
    (pos.row - 1, pos.col)
  of East:
    (pos.row, pos.col + 1)
  of South:
    (pos.row + 1, pos.col)
  of West:
    (pos.row, pos.col - 1)

const Infinity = 100_000_000

proc shortestPathLengths(rooms: Rooms): Table[Position, int] =
  ## Build the table of shortest path lengths for each room.
  let n = rooms.len
  result = [((0, 0), 0)].toTable()
  while result.len < n:
    for (pos, length) in result.pairs.toSeq():
      for dir in Direction.low..Direction.high:
        if rooms[pos][dir] in ['-', '|']:
          let nextPos = pos.getPosition(dir)
          if result.getOrDefault(nextPos, Infinity) > length + 1:
            result[nextPos] = length + 1

# Build the map or rooms.
var pos: Position = (0, 0)
rooms.build(regexp, 0, pos)
rooms.sort(roomCmp)

# Find shortest paths for each room.
let pathLengths = rooms.shortestPathLengths()


### Part 1 ###

# Find the room with the longest shortest path.
var maxLength = 0
for pos, length in pathLengths.pairs:
  if length > maxLength:
    maxLength = length
echo "Part 1: ", maxLength


### Part 2 ###

# Find the number of rooms with a shortest path of at least 1000.
var count = 0
for coords, length in pathLengths.pairs:
  if length >= 1000:
    inc count
echo "Part 2: ", count
