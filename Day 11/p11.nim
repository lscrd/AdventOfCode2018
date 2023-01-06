const SN = 8772

# Grid as an array of rows. Note that first indice is "y".
var grid: array[1..300, array[1..300, int]]

# Fill grid full power level.
for x in 1..300:
  let rackId = x + 10
  for y in 1..300:
    grid[y][x] = (rackId * y + SN) * rackId mod 1000 div 100 - 5


### Part 1 ###

# Find the 3x3 block with higher power level.
var bestPowerLevel = -6
var bestxy: tuple[x, y: int]
for x in 1..298:
  for y in 1..298:
    var powerLevel = 0
    for dx in 0..2:
      for dy in 0..2:
        inc powerLevel, grid[y + dy][x + dx]
    if powerLevel > bestPowerLevel:
      bestPowerLevel = powerLevel
      bestxy = (x, y)

echo "Part 1: ", bestxy.x, ',', bestxy.y


### Part 2 ###

# Array to compute levels incrementally.
var levels: array[1..300, array[1..300, int]]

# Initialize levels for size 1.
bestPowerLevel = -6
var best: tuple[x, y, size: int]
for x in 1..300:
  for y in 1..300:
    let level = grid[y][x]
    levels[y][x] = level
    if level > bestPowerLevel:
      bestPowerLevel = level
      best = (x, y, 1)

# Find the block with higher power level.
for size in 2..300:
  let delta = size - 1
  for x in 1..(300 - delta):
    for y in 1..(300 - delta):
      var level =  levels[y][x] + grid[y + delta][x + delta]
      for x1 in x..<(x + delta):
        inc level, grid[y + delta][x1]
      for y1 in y..<(y + delta):
        inc level, grid[y1][x + delta]
      levels[y][x] = level
      if level > bestPowerLevel:
        bestPowerLevel = level
        best = (x, y, size)

echo "Part 2: ", best.x, ',', best.y, ',', best.size
