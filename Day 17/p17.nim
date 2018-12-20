import strutils
import strscans

type Coords = tuple[x, y: int]

# Parse the lines.
var lines: seq[tuple[xrange, yrange: Slice[int]]]   # List of parsed lines.
var x1, x2, y1, y2: int
var xmin, ymin = 10000
var xmax, ymax = -1
for line in "data".lines:
  if line.scanf("x=$i, y=$i..$i", x1, y1, y2):
    x2 = x1
  elif line.scanf("y=$i, x=$i..$i", y1, x1, x2):
    y2 = y1
  else:
    quit "Error while parsing data."
  if x1 < xmin: xmin = x1
  if y1 < ymin: ymin = y1
  if x2 > xmax: xmax = x2
  if y2 > ymax: ymax = y2
  lines.add((Slice[int](a: x1, b: x2), Slice[int](a: y1, b: y2)))

# Create the map.
dec xmin                      # Add one square to the left.
inc xmax                      # Add one square to the right.
let xsize = xmax - xmin + 1
var map = newSeq[seq[char]](ymax + 1)
for item in map.mitems:
  item = newSeq[char](xsize)
  for c in item.mitems: c = '.'
map[0][500 - xmin] = '+'

# Fill the map.
for line in lines:
  for y in line.yrange:
    for x in line.xrange:
      map[y][x - xmin] = '#'

# Display the map.
proc display(map: seq[seq[char]]) {.used.} =
  for row in map:
    echo row.join()
  echo ""

# Simulate water flowing.
proc simulate(map: var seq[seq[char]]; xmin, xmax: int) =
  var waterPoints: seq[Coords] = @[(500 - xmin, 0)]
  var mapChanged = true

  while mapChanged:
    mapChanged = false
    let prevcount = waterPoints.len

    for idx in 0..waterPoints.high:
      let point = waterPoints[idx]
      var checkSides = false
      var (x, y) = point
      if point.y == map.high:
        continue

      # Check down.
      let yp = y + 1
      let c = map[yp][x]
      if c == '.':
        waterPoints.add((x, yp))
        map[yp][x] = '|'
      elif c == '|':
        # Already processed.
        continue
      elif c in ['#', '~']:
        checkSides = true

      # Check sides.
      # Search for '#' (or '~') to the left.
      if checkSides and map[y][x] != '~':
        var leftBlocked = false
        for xp in countdown(x - 1, 0, 1):
          if map[y][xp] in ['#', '~']:
            leftBlocked = true
            break
          if y == map.high or map[y + 1][xp] notin ['#', '~']:
            # Encountered a square without '#' or '~' under it.
            break
        # Search for '#' (or '~') to the right.
        var rightBlocked = false
        for xp in (x + 1)..xmax:
          if map[y][xp] in ['#', '~']:
            rightBlocked = true
            break
          if y == map.high or map[y + 1][xp] notin ['#', '~']:
            # Encountered a square without '#' or '~' under it.
            break
        # Adjust the status of squares.
        var c = '|'
        if leftBlocked and rightBlocked:
          # Change current square from '|' to '~'.
          map[y][x] = '~'
          mapChanged = true
          c = '~'   # Next squares
        # Change status of left squares either to '|' (flowing) or '~' (resting).
        for xp in countdown(x - 1, 0, 1):
          if map[y][xp] == '.':
            waterPoints.add((xp, y))
            map[y][xp] = c
          else:
            # Already processed or encountered '#'.
            break
          if y == map.high or map[y + 1][xp] notin ['#', '~']:
            # Encountered a square without '#' or '~' under it. Stop modifications.
            break
        # Change status of right squares either to '|' (flowing) or '~' (resting).
        for xp in (x + 1)..xmax:
          if map[y][xp] == '.':
            waterPoints.add((xp, y))
            map[y][xp] = c
          else:
            # Already processed or encountered '#'.
            break
          if y == map.high or map[y + 1][xp] notin ['#', '~']:
              # Encountered a square without '#' or '~' under it. Stop modifications.
              break

    if waterPoints.len != prevcount:
      mapChanged = true


map.simulate(xmin, xmax - xmin)
var count1, count2 = 0

# Count water squares.
for y in ymin..ymax:
  for c in map[y]:
    if c == '|':
      inc count1
    elif c == '~':
      inc count2
echo "Part 1: ", count1 + count2
echo "Part 2: ", count2
