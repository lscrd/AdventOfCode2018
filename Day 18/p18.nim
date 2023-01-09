import std/strutils

type
  Area = seq[string]
  Position = tuple[row, col: int]

let start: Area = readFile("p18.data").splitLines()

proc display(area: Area) {.used.} =
  ## Display the map.
  for row in area:
    echo row
  echo()

iterator adjacentPos(area: Area; pos: Position): char =
  ## Yield the positions adjacent to the given position.
  let maxRow = area.high
  let maxCol = area[0].high
  for row in (pos.row - 1)..(pos.row + 1):
    if row < 0 or row > maxRow: continue
    for col in (pos.col - 1)..(pos.col + 1):
      if col < 0 or col > maxCol: continue
      if row != pos.row or col != pos.col:
        yield area[row][col]

proc willBecomeTrees(area: Area; pos: Position): bool =
  ## Return true if the acre at given position will become a tree acre.
  var count = 0
  for acre in area.adjacentPos(pos):
    if acre == '|':
      inc count
      if count == 3:
        return true

proc willBecomeLumberyard(area: Area; pos: Position): bool =
  ## Return true if the acre at given position will become a lumberyard acre.
  var count = 0
  for acre in area.adjacentPos(pos):
    if acre == '#':
      inc count
      if count == 3:
        return true

proc willBecomeOpen(area: Area, pos: Position): bool =
  ## Return true if the acre at given position will become an open acre.
  result = true
  var trees, lumberyards = 0
  for acre in area.adjacentPos(pos):
    if acre == '#':
      inc lumberyards
      if trees >= 1:
        return false
    elif acre == '|':
      inc trees
      if lumberyards >= 1:
        return false

proc next(area: Area): Area =
  ## Return the next configuration of the area.
  result.setLen(area.len)
  let rowLength = area[0].len
  for row, acreRow in area:
    result[row].setLen(rowLength)
    for col, acre in acreRow:
      let pos: Position = (row, col)
      if acre == '.':
        result[row][col] = (if area.willBecomeTrees(pos): '|' else: '.')
      elif acre == '|':
        result[row][col] = (if area.willBecomeLumberyard(pos): '#' else: '|')
      else:
        result[row][col] = (if area.willBecomeOpen(pos): '.' else: '#')

proc resourceValue(area: Area): int =
  ## Return the resource value of the area.
  var trees = 0
  var lumberyards = 0
  for acreRow in area:
    for acre in acreRow:
      if acre == '|':
        inc trees
      elif acre == '#':
        inc lumberyards
  result = trees * lumberyards


### Part 1 ###

var area = start
for _ in 1..10:
  area = area.next()

echo "Part 1: ", area.resourceValue()


### Part 2 ###

# After some generations, the area reproduces the same configuration according to a cycle.

# Find the cycle length.
area = start
var areas = @[area]
var n = 0
var pos: int
while true:
  inc n
  area = area.next()
  pos = areas.find(area)
  if pos >= 0: break
  areas.add area
let cycleLength = n - pos

let remaining = (1000 - n) mod cycleLength
for _ in 1..remaining:
  area = area.next()

echo "Part 2: ", area.resourceValue()
