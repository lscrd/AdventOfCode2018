import sequtils
import strutils

type
  Area = seq[seq[char]]
  Coords = tuple[row, col: int]

var area: Area

for line in "data".lines:
  area.add(line.toSeq())

proc display(area: Area) =
  for row in area:
    echo row.join()
  echo ""

iterator adjacentCells(area: Area, coords: Coords): char =
  let maxrow = area.high
  let maxcol = area[0].high
  for row in (coords.row - 1)..(coords.row + 1):
    if row < 0 or row > maxrow: continue
    for col in (coords.col - 1)..(coords.col + 1):
      if col < 0 or col > maxcol: continue
      if row != coords.row or col != coords.col:
        yield area[row][col]

proc willBecomeTrees(area: Area, coords: Coords): bool =
  var count = 0
  for cell in area.adjacentCells(coords):
    if cell == '|':
      inc count
      if count == 3:
        return true

proc willBecomeLumberyard(area: Area, coords: Coords): bool =
  var count = 0
  for cell in area.adjacentCells(coords):
    if cell == '#':
      inc count
      if count == 3:
        return true

proc willBecomeOpen(area: Area, coords: Coords): bool =
  result = true
  var trees, lumberyards = 0
  for cell in area.adjacentCells(coords):
    if cell == '#':
      inc lumberyards
      if trees >= 1:
        return false
    elif cell == '|':
      inc trees
      if lumberyards >= 1:
        return false

proc next(area: Area): Area =
  result.setLen(area.len)
  let rowlength = area[0].len
  for row, cellrow in area:
    result[row].setLen(rowLength)
    for col, cell in cellrow:
      let coords: Coords = (row, col)
      if cell == '.':
        result[row][col] = (if area.willBecomeTrees(coords): '|' else: '.')
      elif cell == '|':
        result[row][col] = (if area.willBecomeLumberyard(coords): '#' else: '|')
      else:
        result[row][col] = (if area.willBecomeOpen(coords): '.' else: '#')

proc resourceValue(area: Area): int =
  var trees = 0
  var lumberyards = 0
  for cellrow in area:
    for cell in cellrow:
      if cell == '|':
        inc trees
      elif cell == '#':
        inc lumberyards
  result = trees * lumberyards

area.display()
for _ in 1..10:
  area = area.next
area.display()

echo area.resourceValue
