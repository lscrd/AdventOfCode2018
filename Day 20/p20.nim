import tables
import strutils

type
  Coords = tuple[row, col: int]
  Direction = enum North, East, South, West
  Walls = array[Direction, char]
  Rooms = OrderedTable[Coords, Walls]

var
  rooms = initOrderedTable[Coords, Walls]()   # Each room has four walls.
  regexp = "data".readFile()

const EMPTY = ['?', '?', '?', '?']    # Initial value for the walls of a room.

# Build the rooms description.
proc build(rooms: var Rooms, regexp: string, start: int, coords: Coords): int =
  result = start
  var coords = coords
  while true:
    case regexp[result]

    of '^':
      rooms[coords] = EMPTY
      inc result

    of 'N':
      rooms[coords][North] = '-'
      dec coords.row
      rooms.mgetOrPut((coords.row, coords.col), EMPTY)[South] = '-'
      inc result

    of 'E':
      rooms[coords][East] = '|'
      inc coords.col
      rooms.mgetOrPut((coords.row, coords.col), EMPTY)[West] = '|'
      inc result

    of 'S':
      rooms[coords][South] = '-'
      inc coords.row
      rooms.mgetOrPut((coords.row, coords.col), EMPTY)[North] = '-'
      inc result

    of 'W':
      rooms[coords][West] = '|'
      dec coords.col
      rooms.mgetOrPut((coords.row, coords.col), EMPTY)[East] = '|'
      inc result

    of '(':
      while true:
        # Process each part of the subexpression.
        result = rooms.build(regexp, result + 1, coords)
        if regexp[result] == ')':
          inc result
          break

    of '|', ')':
      break

    of '$':
      # Adjust walls.
      for c, walls in rooms.pairs:
        for dir, wall in walls:
          if wall == '?':
            rooms[c][dir] = '#'
      break

    else:
      discard

# Compare two room élements in the room table. To be used by "sort".
proc roomcmp(x, y: (Coords, Walls)): int = cmp(x[0], y[0])

# Display the map of the rooms.
proc display(rooms: Rooms) {.used.} =
  const none = -10000000
  var map: seq[string]
  var row = none
  for coords, walls in rooms.pairs:
    if row != coords.row:
      row = coords.row
      map.add("#")
      map.add("#")
    map[^2].add(walls[North])
    map[^2].add('#')
    map[^1].add('.')
    map[^1].add(walls[East])
  # Add last line.
  map.add("#".repeat(map[0].len))
  # Draw the map.
  for line in map:
    echo line

# Return the coordinates of the room located at direction "dir' from room at "coords".
proc getCoords(coords: Coords, dir: Direction): Coords =
  case dir
  of North:
    (coords.row - 1, coords.col)
  of East:
    (coords.row, coords.col + 1)
  of South:
    (coords.row + 1, coords.col)
  of West:
    (coords.row, coords.col - 1)

const INFINITY = 100000000

# Build the table of shortest path lengths for each room.
proc shortestPathLengths(rooms: Rooms): Table[Coords, int] =
  let n = rooms.len
  result = [((0, 0), 0)].toTable()
  while result.len < n:
    for coords, length in result.pairs:
      for dir in Direction.low..Direction.high:
        if rooms[coords][dir] in ['-', '|']:
          let nextCoords = coords.getCoords(dir)
          if result.getOrDefault(nextCoords, INFINITY) > length + 1:
            result[nextCoords] = length + 1

var coords: Coords = (0, 0)
discard rooms.build(regexp, 0, coords)
rooms.sort(roomcmp)
# Find shortest paths for each room.
let pathLengths = rooms.shortestPathLengths()

#######################################################
# Part 1: find the room with the longest shortest path.
var maxLength = 0
for coords, length in pathLengths.pairs:
  if length > maxLength:
    maxLength = length
echo "Part 1: ", maxLength

#########################################################################
# Part 2: find the number of rooms with a shortest path of at least 1000.
var count = 0
for coords, length in pathLengths.pairs:
  if length >= 1000:
    inc count
echo "Part 2: ", count
